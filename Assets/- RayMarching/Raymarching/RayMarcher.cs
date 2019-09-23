using UnityEngine;
using Raymarching.RaymarchingEntities;

namespace Raymarching
{
    [RequireComponent(typeof(Camera))]
    public class RayMarcher : MonoBehaviour
    {
        public ComputeShader RayMarchingShader;
        private RenderTexture _target;
        private Camera _camera;
        private int _mainKernelID;
        private int _width;
        private int _height;
        public Texture SkyboxTexture;
        public Light directionalLight;

        private void Awake()
        {
            _camera = GetComponent<Camera>();
            _mainKernelID = RayMarchingShader.FindKernel("CSMain");
            RayMarchingShader.SetTexture(0, "_SkyboxTexture", SkyboxTexture);
            transform.hasChanged = true;
        }

        private void UpdateShaderParameters()
        {
            //update target dimensions
            if (_width != _camera.pixelWidth || _height != _camera.pixelHeight)
            {
                _width = _camera.pixelWidth;
                _height = _camera.pixelHeight;
                RayMarchingShader.SetInt("_Width", _width);
                RayMarchingShader.SetInt("_Height", _height);
            }

            //update camera position
            if (transform.hasChanged)
            {
                RayMarchingShader.SetMatrix("_Camera2World", _camera.cameraToWorldMatrix);
                RayMarchingShader.SetMatrix("_CameraInverseProjection", _camera.projectionMatrix.inverse);

                transform.hasChanged = false;
            }

            //update light direction
            if (directionalLight.transform.hasChanged)
            {
                Vector3 l = directionalLight.transform.forward;
                RayMarchingShader.SetVector("_DirectionalLight",
                    new Vector4(l.x, l.y, l.z, directionalLight.intensity));
            }

            //update entities
            if (RaymarchingEntityManager.Dirty)
            {
                RayMarchingShader.SetBuffer(_mainKernelID, "_RMEntities", RaymarchingEntityManager.EntityBuffer);
                RayMarchingShader.SetInt("_RMEntitiesCount", RaymarchingEntityManager.EntityBuffer.count);
            }
        }

        private void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            UpdateShaderParameters();
            Render(destination);
        }

        private void Render(RenderTexture destination)
        {
            // Make sure we have a current render target
            InitRenderTexture();
            // Set the target and dispatch the compute shader
            RayMarchingShader.SetTexture(_mainKernelID, "Result", _target);
            var threadGroupsX = Screen.width / 32;
            var threadGroupsY = Screen.height / 32;
            RayMarchingShader.Dispatch(0, threadGroupsX, threadGroupsY, 1);
            Graphics.Blit(_target, destination);
        }

        private void InitRenderTexture()
        {
            if (_target == null || _target.width != Screen.width || _target.height != Screen.height)
            {
                // Release render texture if we already have one
                if (_target != null)
                    _target.Release();
                // Get a render target for Ray Tracing
                _target = new RenderTexture(Screen.width, Screen.height, 0,
                    RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
                _target.enableRandomWrite = true;
                _target.Create();
            }
        }
    }
}
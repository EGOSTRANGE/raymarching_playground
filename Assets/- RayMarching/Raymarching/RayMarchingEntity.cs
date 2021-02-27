using System;
using UnityEngine;
using Unity.Mathematics;

namespace Raymarching.RaymarchingEntities
{
    public class RayMarchingEntity : MonoBehaviour
    {
        [Serializable]
        public struct RayMarchingEntityData
        {
            public enum RayMarchingEntityShape
            {
                None,
                SDF_XYPlane,
                SDF_YZPlane,
                SDF_XZPlane,
                SDF_Plane,
                SDF_Sphere,
                SDF_Cube,
                SDF_RoundBox,
                SDF_Torus,
                SDF_Cylinder,
                SDF_Cone,
                SDF_HexPrism,
                SDF_TriPrism,
                SDF_Capsule_NOT_READY_YET,
                SDF_VertCapsule,
                SDF_CappedCylinder,
                SDF_RoundedCylinder,
                SDF_CappedCone,
                SDF_RoundCone,
                SDF_Elipsoid,
                SDF_Octahedron,
                SDF_Octahedron_EXACT,
                SDF_Triangle_UD_NOT_READY_YET,
                SDF_Quad_UD_NOT_READY_YET,
            }

            [HideInInspector] public float4x4 inverseTransform;

            public RayMarchingEntityShape shape;

            public float3 albedo;

            [Range(0, 1)] public float roughness;

            public float4 settings;
            public float3 bBoxScale;
            public float3 bBoxoffset;
        };


        [SerializeField] public RayMarchingEntityData data;
        public int _id;

        private void OnEnable()
        {
            _id = RaymarchingEntityManager.RegisterEntity(this);
        }

        private void OnDisable()
        {
            RaymarchingEntityManager.UnregisterEntity(_id);
        }

        void Update()
        {
            var tr = transform;
            if (tr.hasChanged)
            {
                data.inverseTransform = tr.worldToLocalMatrix;
                tr.hasChanged = false;
                RaymarchingEntityManager.UpdateEntity(data, _id);
            }
        }
    }
}
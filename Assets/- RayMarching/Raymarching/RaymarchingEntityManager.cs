using UnityEngine;

namespace Raymarching.RaymarchingEntities
{
    public class RaymarchingEntityManager : MonoBehaviour
    {
        public static bool Dirty { get; private set; }

        public static int MaxEntityAmount = 10;
        
        
        public static int RayMarchingEntityCount { get; private set; }
        
        private static readonly int RayMarchingEntityStride;
        
        public static ComputeBuffer EntityBuffer
        {
            get
            {
                if (Dirty)
                    UpdateEntityBuffer();
                return _entityBuffer;
            }
        }

        private static ComputeBuffer _entityBuffer;
        private static RayMarchingEntity[] _entities;
        private static RayMarchingEntity.RayMarchingEntityData[] _entitiesData;
        
        static RaymarchingEntityManager()
        {
            //shape
            // (int) 4
            RayMarchingEntityStride = sizeof(RayMarchingEntity.RayMarchingEntityData.RayMarchingEntityShape);

            //transform
            // (float4x4) 4*4*4
            RayMarchingEntityStride += sizeof(float) * 4 * 4;

            //settings
            // (float4)
            RayMarchingEntityStride += sizeof(float) * 4;

            //albedo
            // (float3)
            RayMarchingEntityStride += sizeof(float) * 3;

            //roughness
            // (float)
            //TODO: thing to look for: if this can be made into a half value (if that structure can be maintained into c#)
            RayMarchingEntityStride += sizeof(float);
            
            //bbox scale
            RayMarchingEntityStride += sizeof(float)*3;

            //bbox offset
            RayMarchingEntityStride += sizeof(float)*3;
            
            _entities = new RayMarchingEntity[MaxEntityAmount];
            _entitiesData = new RayMarchingEntity.RayMarchingEntityData[MaxEntityAmount];
            //_entityBuffer = new ComputeBuffer(MaxEntityAmount, RayMarchingEntityStride);
            RayMarchingEntityCount = 0;
        }

        public static void Swap<T>(T[] list, int a, int b)
        {
            var temp = list[a];
            list[a] = list[b];
            list[b] = temp;
        }

        public static int RegisterEntity(RayMarchingEntity entity)
        {
            if (RayMarchingEntityCount >= MaxEntityAmount) return -1;

            _entities[RayMarchingEntityCount] = entity;
            var id = RayMarchingEntityCount;
            RayMarchingEntityCount++;
            Dirty = true;
            return id;
        }

        public static void UpdateEntity(RayMarchingEntity.RayMarchingEntityData data, int id)
        {
            _entitiesData[id] = data;
            Dirty = true;
        }

        public static void UnregisterEntity(int id)
        {
            Swap(_entities, id, RayMarchingEntityCount - 1);
            RayMarchingEntityCount--;
            Dirty = true;
        }


        private static void UpdateEntityBuffer()
        {

            var entitiesDataArray = new RayMarchingEntity.RayMarchingEntityData[MaxEntityAmount];

            for (int i = 0; i < RayMarchingEntityCount; i++)
            {
                entitiesDataArray[i] = _entities[i].data;
            }

            if (_entityBuffer == null)
            {
                _entityBuffer = new ComputeBuffer(MaxEntityAmount, RayMarchingEntityStride);
                Debug.Log("Remake entity buffer");
            }

            if (_entityBuffer.count != MaxEntityAmount)
            {
                Debug.Log("Count different");
                _entityBuffer.Release();
                _entityBuffer = new ComputeBuffer(MaxEntityAmount, RayMarchingEntityStride);
            }

            //TODO: transform this to only update the necessary entities instead of copy the entire array
            _entityBuffer.SetData(entitiesDataArray, 0, 0, RayMarchingEntityCount);
            Dirty = false;
        }
    }
}
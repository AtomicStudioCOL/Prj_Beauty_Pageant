/*

    Copyright (c) 2024 Pocketz World. All rights reserved.

    This is a generated file, do not edit!

    Generated by com.pz.studio
*/

#if UNITY_EDITOR

using System;
using System.Linq;
using UnityEngine;
using Highrise.Client;

namespace Highrise.Lua.Generated
{
    [AddComponentMenu("Lua/TrackingPlayersLobby")]
    [LuaBehaviourScript(s_scriptGUID)]
    public class TrackingPlayersLobby : LuaBehaviourThunk
    {
        private const string s_scriptGUID = "6feeb83f32044a54f9bee0a9c74cbdb4";
        public override string ScriptGUID => s_scriptGUID;

        [SerializeField] public System.Double m_minNumPlayersStartRound = 4;

        protected override SerializedPropertyValue[] SerializeProperties()
        {
            if (_script == null)
                return Array.Empty<SerializedPropertyValue>();

            return new SerializedPropertyValue[]
            {
                CreateSerializedProperty(_script.GetPropertyAt(0), m_minNumPlayersStartRound),
            };
        }
    }
}

#endif

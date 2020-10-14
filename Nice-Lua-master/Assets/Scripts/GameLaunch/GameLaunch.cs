﻿using Addressable;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;
using XLua;
using XLua.LuaDLL;
using GamePlay;

#if !UNITY_EDITOR
using Addressable;
#endif
using FlatBuffers;
using fb;

[Hotfix]
[LuaCallCSharp]
public class GameLaunch : MonoBehaviour
{
 
    const string launchPrefabPath = "UI/Prefabs/View/UILaunch.prefab";
    const string noticeTipPrefabPath = "UI/Prefabs/Common/UINoticeTip.prefab";
    GameObject launchPrefab;
    GameObject noticeTipPrefab;
    AddressableUpdater updater;

    IEnumerator Start ()
    {
        LoggerHelper.Instance.Startup();
        //注释掉IOS的推送服务
        //#if UNITY_IPHONE
        //        UnityEngine.iOS.NotificationServices.RegisterForNotifications(UnityEngine.iOS.NotificationType.Alert | UnityEngine.iOS.NotificationType.Badge | UnityEngine.iOS.NotificationType.Sound);
        //        UnityEngine.iOS.Device.SetNoBackupFlag(Application.persistentDataPath);
        //#endif

        var start = DateTime.Now;

        // 启动资源管理模块
        start = DateTime.Now;
        yield return AddressablesManager.Instance.Initialize();
        Logger.Log(string.Format("AssetBundleManager Initialize use {0}ms", (DateTime.Now - start).Milliseconds));

        // 启动xlua热修复模块
        start = DateTime.Now;
        XLuaManager.Instance.Startup();


#if !UNITY_EDITOR
        //预加载Lua
        BaseAssetAsyncLoader loader = AddressablesManager.Instance.LoadAssetAsync(AddressableConfig.AssetsPathMapFileName, typeof(TextAsset));
        yield return loader;

        TextAsset maptext = loader.asset as TextAsset;
        string[] luas = maptext.text.Split(new string[] { "\r\n" }, StringSplitOptions.RemoveEmptyEntries);

        AddressablesManager.Instance.ReleaseAsset(loader.asset);
        loader.Dispose();
        LuaAsyncLoader luaLoader = AddressablesManager.Instance.LoadLuaAsync(luas);
        yield return luaLoader;
#endif

        XLuaManager.Instance.OnInit();
       // XLuaManager.Instance.StartHotfix();
        Logger.Log(string.Format("XLuaManager StartHotfix use {0}ms", (DateTime.Now - start).Milliseconds));

        // 初始化UI界面
        yield return InitLaunchPrefab();
        yield return null;
        yield return InitNoticeTipPrefab();

        
        // 开始更新
        if (updater != null)
        {
            updater.StartCheckUpdate();
        }
        yield break;
	}


    GameObject InstantiateGameObject(GameObject prefab)
    {
        var start = DateTime.Now;
        GameObject go = GameObject.Instantiate(prefab);
        Logger.Log(string.Format("Instantiate use {0}ms", (DateTime.Now - start).Milliseconds));

        var luanchLayer = GameObject.Find("UIRoot/LuanchLayer");
        go.transform.SetParent(luanchLayer.transform);
        var rectTransform = go.GetComponent<RectTransform>();
        rectTransform.offsetMax = Vector2.zero;
        rectTransform.offsetMin = Vector2.zero;
        rectTransform.localScale = Vector3.one;
        rectTransform.localPosition = Vector3.zero;

        return go;
    }

    IEnumerator InitNoticeTipPrefab()
    {
        var start = DateTime.Now;

        AsyncOperationHandle<GameObject> handle = Addressables.LoadAssetAsync<GameObject>(noticeTipPrefabPath);
        yield return handle;
        if(handle.Status == AsyncOperationStatus.Succeeded)
        {
            Logger.Log(string.Format("Load noticeTipPrefab use {0}ms", (DateTime.Now - start).Milliseconds));
           
            noticeTipPrefab = handle.Result;
            var go = InstantiateGameObject(noticeTipPrefab);
            UINoticeTip.Instance.UIGameObject = go;
            yield break;
        }
        else
        {
            Logger.LogError("LoadAssetAsync noticeTipPrefab err : " + noticeTipPrefabPath);
            yield break;
        }
        
    }

    IEnumerator InitLaunchPrefab()
    {
        var start = DateTime.Now;

        AsyncOperationHandle<GameObject> handle = Addressables.LoadAssetAsync<GameObject>(launchPrefabPath);
        yield return handle;
        if(handle.Status == AsyncOperationStatus.Succeeded)
        {
            Logger.Log(string.Format("Load launchPrefab use {0}ms", (DateTime.Now - start).Milliseconds));
            
            launchPrefab = handle.Result;
            var go = InstantiateGameObject(launchPrefab);
            updater = go.AddComponent<AddressableUpdater>();
            yield break;
        }
        else
        {
            Logger.LogError("LoadAssetAsync launchPrefab err : " + launchPrefabPath);
            yield break;
        }

    }
}

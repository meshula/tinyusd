//
//  tinyusd_SceneProxy.h
//  TinyUSDTester
//
//  Copyright © 2019 Nick Porcino
//

#ifndef SceneProxy_h
#define SceneProxy_h

#ifdef _MSC_VER
#pragma warning(disable:4244)
#pragma warning(disable:4305)
#endif

#include <pxr/base/tf/weakBase.h>
#include <pxr/base/tf/weakPtr.h>
#include <pxr/usd/usd/notice.h>
#include <pxr/usd/usd/prim.h>
#include <pxr/usd/usd/stage.h>
#include <pxr/usd/usdGeom/xformable.h>

PXR_NAMESPACE_USING_DIRECTIVE

class SceneProxy : public TfWeakBase         // in order to register for Tf events
{
    // For changes from UsdStage.
    TfNotice::Key _objectsChangedNoticeKey;
    UsdStageRefPtr stage;
public:

    ~SceneProxy();

    void _OnObjectsChanged(UsdNotice::ObjectsChanged const& notice, UsdStageWeakPtr const& sender);

    void create_new_stage(std::string const& path);
    void load_stage(std::string const& filePath);
    void save_stage();
};


#endif /* SceneProxy_h */

#ifdef TINYUSD_SCENEPROXY_DRY

SceneProxy::~SceneProxy()
{
    TfNotice::Revoke(_objectsChangedNoticeKey);
}

void SceneProxy::_OnObjectsChanged(UsdNotice::ObjectsChanged const& notice, UsdStageWeakPtr const& sender)
{
    printf("GetResyncedPaths\n");
    auto pathsToResync = notice.GetResyncedPaths();
    for (auto & i : pathsToResync)
    {
        printf("%s\n", i.GetString().c_str());
    }
    printf("GetChangedInfoOnlyPaths\n");
    auto infoPaths = notice.GetChangedInfoOnlyPaths();
    for (auto & i : infoPaths)
    {
        printf("%s\n", i.GetString().c_str());
    }
}

void SceneProxy::create_new_stage(std::string const& path)
{
    TfNotice::Revoke(_objectsChangedNoticeKey);

    stage = UsdStage::CreateNew(path);

    // Start listening for change notices from this stage.
    auto self = TfCreateWeakPtr(this);
    _objectsChangedNoticeKey = TfNotice::Register(self, &SceneProxy::_OnObjectsChanged, stage);

    // create a cube on the stage
    stage->DefinePrim(SdfPath("/Box"), TfToken("Cube"));
    UsdPrim cube = stage->GetPrimAtPath(SdfPath("/Box"));
    GfVec3f scaleVec = { 5.f, 5.f, 5.f };
    UsdGeomXformable cubeXf(cube);
    cubeXf.AddScaleOp().Set(scaleVec);
}

void SceneProxy::load_stage(std::string const& filePath)
{
    printf("\nLoad_Stage : %s\n", filePath.c_str());
    auto supported = UsdStage::IsSupportedFile(filePath);
    if (supported)
    {
        printf("File format supported\n");
    }
    else
    {
        fprintf(stderr, "%s : File format not supported\n", filePath.c_str());
        return;
    }

    UsdStageRefPtr loadedStage = UsdStage::Open(filePath);

    if (loadedStage)
    {
        auto pseudoRoot = loadedStage->GetPseudoRoot();
        printf("Pseudo root path: %s\n", pseudoRoot.GetPath().GetString().c_str());
        for (auto const& c : pseudoRoot.GetChildren())
        {
            printf("\tChild path: %s\n", c.GetPath().GetString().c_str());
        }
    }
    else
    {
        fprintf(stderr, "Stage was not loaded");
    }
}

void SceneProxy::save_stage()
{
    if (stage)
        stage->GetRootLayer()->Save();
}


#endif
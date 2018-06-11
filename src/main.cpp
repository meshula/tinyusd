
#pragma warning(disable:4244)
#pragma warning(disable:4305)

#include <pxr/base/tf/weakBase.h>
#include <pxr/base/tf/weakPtr.h>
#include <pxr/usd/usd/notice.h>
#include <pxr/usd/usd/prim.h>
#include <pxr/usd/usd/stage.h>
#include <pxr/usd/usdGeom/xformable.h>

PXR_NAMESPACE_USING_DIRECTIVE

class SceneProxy
: public TfWeakBase         // in order to register for Tf events
{
    // For changes from UsdStage.
    TfNotice::Key _objectsChangedNoticeKey;
    UsdStageRefPtr stage;
public:

    ~SceneProxy()
    {
        TfNotice::Revoke(_objectsChangedNoticeKey);
    }

    void _OnObjectsChanged(UsdNotice::ObjectsChanged const& notice, UsdStageWeakPtr const& sender)
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

    void create_new_stage(const std::string& path)
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

    void save_stage()
    {
        if (stage)
            stage->GetRootLayer()->Save();
    }

};


int main(char** argv, int argc)
{
    SceneProxy scene;
    scene.create_new_stage("C:\\TMP\\test.usda");
    scene.save_stage();
    return 0;
}

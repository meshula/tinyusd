
#import "SceneProxy.h"

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

//int main(char** argv, int argc)
//{
//    Plug_InitConfig();
//    SceneProxy scene;
//    scene.create_new_stage("C:\\TMP\\test.usda");
//    scene.save_stage();
//
//    SceneProxy scene2;
//    scene2.load_stage("C:\\TMP\\test.usda");
//
//    return 0;
//}

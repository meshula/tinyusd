
#define TINYUSD_SCENEPROXY_DRY
#include "tinyusd_SceneProxy.h"

int main(int argc, char** argv)
{
    SceneProxy scene;
    scene.create_new_stage("test.usda");
    scene.save_stage();

    SceneProxy scene2;
    scene2.load_stage("test.usda");

    return 0;
}

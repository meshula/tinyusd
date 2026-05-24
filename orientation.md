# Tiny USD - Project Orientation

## Project Overview

**Educational USD tutorial project** demonstrating how to create the smallest possible viable USD (Universal Scene Description) programs using Pixar's official USD distribution. This project tackles one of the biggest barriers to USD adoption - the notoriously complex build process.

### Mission Statement

To provide clear, minimal examples and build recipes that help developers understand and integrate USD into their projects without getting overwhelmed by USD's extensive feature set and complex build requirements.

## Project Characteristics

### Core Program
- **Hello Cube**: Minimal C++ program that creates a simple cube geometry
- **File**: `src/main.cpp` (42 lines including comments)
- **Output**: Creates `cube.usda` file with basic USD scene description
- **Dependencies**: Core USD libraries (UsdStage, UsdGeom)

### Build Recipe System

**Philosophy**: Different projects need different USD configurations

**Recipe Status** (as of current):
- ✅ **MacOS dynamic (no python)** - Complete
- ✅ **MacOS dynamic (python)** - Complete
- ✅ **MacOS static monolithic (no python)** - Complete
- 🚧 **MacOS static (no python)** - Work in progress
- 🚧 **Windows dynamic (no python)** - Work in progress
- ❓ **Ubuntu** - Mentioned as "a struggle"

## Technical Architecture

### Source Structure
```
tinyusd/
├── src/
│   └── main.cpp              # Minimal "Hello Cube" USD program
├── include/
│   └── tinyusd_SceneProxy.h   # USD scene management wrapper
├── cmake/
│   ├── FindUsd.cmake          # USD discovery for CMake
│   ├── FindTBB.cmake          # Intel TBB discovery
│   └── Utilities.cmake        # Build utilities
├── recipes/                   # Build configuration recipes
│   ├── macos-dynamic-nopy/    # MacOS dynamic build (no Python)
│   ├── macos-dynamic-py/      # MacOS dynamic build (with Python)
│   ├── macos-ms-nopy/         # MacOS static monolithic
│   └── windows-dynamic-nopy/  # Windows dynamic (WIP)
└── packages/                  # Build output/packaging
```

### Core Dependencies
- **USD (pxr)**: Pixar Universal Scene Description
- **Intel TBB**: Threading Building Blocks
- **OpenGL**: For graphics abstraction (garch)
- **CMake 3.11+**: Modern build system
- **C++17**: Language standard

### Hello Cube Program Analysis
The main program demonstrates:
1. **Stage Creation**: `UsdStage::CreateNew("cube.usda")`
2. **Transform Hierarchy**: Creating root Xform at `/HelloCube`
3. **Geometry Definition**: UsdGeomCube under `/HelloCube/Cube`
4. **Attribute Setting**: Cube size (2x2x2 units)
5. **File I/O**: Saving stage to disk

## USD Context & Significance

### What is USD?
Universal Scene Description (USD) is Pixar's open-source framework for:
- **Scene Description**: 3D scene composition and interchange
- **Pipeline Integration**: VFX/animation production workflows
- **Asset Management**: Layered, non-destructive asset composition
- **Industry Standard**: Adopted by Pixar, Disney, NVIDIA, Apple, others

### Why Tiny USD Matters
1. **Adoption Barrier**: USD's power comes with complexity
2. **Build Complexity**: Official build system is overwhelming
3. **Learning Curve**: Full USD examples are often too complex
4. **Integration Challenge**: Hard to know minimal requirements

### Educational Value
- **Minimal Viable Product**: Demonstrates core USD concepts
- **Build Demystification**: Multiple approaches to USD integration
- **Progressive Complexity**: Start simple, add features incrementally
- **Real-World Focused**: Practical integration patterns

## Build Recipe Philosophy

### Configuration Matrix
Different applications need different USD builds:

**Static vs Dynamic**:
- **Dynamic**: Smaller executables, runtime dependencies
- **Static**: Larger executables, self-contained
- **Monolithic**: Everything in one library (simplest)

**Python vs No Python**:
- **With Python**: Full USD ecosystem, scripting support
- **Without Python**: Reduced dependencies, C++-only

**Platform Considerations**:
- **MacOS**: First-class support, all recipes
- **Windows**: MSVC-specific challenges
- **Linux**: Package manager complications

## Development Context

### Original Motivation
- Author: Nick Porcino (2019+)
- **Problem**: USD integration shouldn't require PhD in build systems
- **Solution**: Curated minimal examples with clear build paths

### Current State
- **Highly work in progress** (per README)
- **MacOS-focused**: Most complete recipe set
- **Community-oriented**: "Help wanted!" for other platforms

## Use Cases

### Learning USD
1. **First USD Program**: Understand basic concepts
2. **Build System Study**: See how USD integrates
3. **Minimal Dependencies**: Learn core requirements

### Production Integration
1. **Prototyping**: Quick USD experiments
2. **Build Template**: Starting point for larger projects
3. **Dependency Analysis**: Understand what you actually need

### Educational Reference
1. **Teaching Material**: Clean examples for USD education
2. **Build Documentation**: Real-world build configurations
3. **Platform Porting**: Templates for new platforms

## Key Files for Understanding

1. **src/main.cpp** - The minimal USD program itself
2. **CMakeLists.txt** - Build integration example
3. **recipes/README.md** - Comprehensive build guide
4. **cmake/FindUsd.cmake** - USD discovery and configuration
5. **include/tinyusd_SceneProxy.h** - USD scene management patterns

## Development Priorities

### Immediate
- **Complete Windows Recipe**: Finish Windows dynamic build
- **Linux/Ubuntu Support**: Tackle package management challenges
- **Documentation**: Expand recipe explanations

### Long-term
- **More Examples**: Additional minimal USD programs
- **Advanced Recipes**: Static builds, custom configurations
- **Integration Patterns**: Real-world usage examples

## Research & Learning Context

This project sits at the intersection of:
- **Computer Graphics**: 3D scene description technology
- **Software Engineering**: Build system design and dependency management
- **Developer Experience**: Making complex tools accessible
- **Industry Standards**: Understanding production pipelines

### Related Technologies
- **OpenUSD**: The broader USD ecosystem
- **Hydra**: USD's rendering framework
- **Material X**: USD material description
- **Alembic**: Alternative scene description format

---

*For immediate orientation: Start with src/main.cpp to see minimal USD in action, then explore recipes/ to understand build approaches. This project makes USD accessible without drowning in complexity.*
# 2026-09-22 running uslam on raspi
for getting depends need githug ssh key  \
for building fast_neon, you need to modify the CmakeLists.txt for it with this:  \
```
IF(DEFINED ENV{ARM_ARCHITECTURE})
        SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -D__ARM_NEON__")
ELSE()
        SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -mmmx -msse -msse -msse2 -msse3 -mssse3 -fomit-frame-pointer")
ENDIF()
```

also changed:  `/home/rasp5/event_ws/src/rpg_ultimate_slam_open/common/ze_cmake/cmake/modules/ze_setup.cmake`  \
replaced #arm block with this:  \
```
# arm
if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|arm64)$")
  add_definitions(-DHAVE_FAST_NEON -D__ARM_NEON__)
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(armv7|arm)$")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mfpu=neon -march=armv7-a")
  add_definitions(-DHAVE_FAST_NEON)
else()
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mmmx -msse -msse -msse2 -msse3 -mssse3")
endif()
```

To prevent OOM error, OS killing the build job -> dont use -j8  \
instead:  \
```
catkin config --make-args -j2  \
catkin build ze_vio_ceres --force-cmake -j1  \
```

## running uslam
```
roslaunch ze_vio_ceres dvx_micro_events_only.launch bag_filename:="~/event_ws/2026-07-27dark_circle1.bag" viz:=false
```

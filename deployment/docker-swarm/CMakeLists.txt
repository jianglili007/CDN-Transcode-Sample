set(service "docker_swarm")
include("${CMAKE_SOURCE_DIR}/script/deployment.cmake")
set(service "docker_compose")
include("${CMAKE_SOURCE_DIR}/script/deployment.cmake")

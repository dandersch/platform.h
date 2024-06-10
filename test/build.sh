#!/bin/bash
# NOTE:
# - cl.exe (and clang-cl.exe) sets itself to C/C++ mode depending on the source
#   file extension, which is why we use have test.cpp symlink
#
# - to get all macros set by the compiler: gcc -dM -E file.c
#
# - switches to create debuggable .exe & separate pdb file with cl.exe:
#   /Zi /link /DEBUG:FULL /PDB:bin/test_msvcxx.pdb
#
# - OS+compilers combinations tested here:
#   linux   + gcc(++)
#   linux   + clang(++)
#   linux   + mingw(++)
#   windows + msvc(++)
#   windows + clang-cl.exe(++)
#   windows + clang(++)
#   linux   + tcc

INCLUDES="-I ./ -I .."
WINCLUDES="/I ./ /I .."

set -e
rm -rf bin
mkdir -p bin
rm -f *.obj

printf "\nclang++ c++11:\n"
clang++ -g ${INCLUDES} -Wno-deprecated -std=c++11 test.c -o bin/test_clangxx && ./bin/test_clangxx

printf "\ng++ c++20:\n"
g++ -g ${INCLUDES} test.c -std=c++20 -o bin/test_gxx && ./bin/test_gxx

printf "\nclang c11:\n"
clang -g ${INCLUDES} -std=c11 test.c -o bin/test_clang && ./bin/test_clang

printf "\ngcc c99 (32bit):\n"
gcc -g ${INCLUDES} -m32 -DBUILD_DEBUG -std=c99 -O2 test.c -o bin/test_gcc && ./bin/test_gcc

printf "\nmingw-g++:\n"
x86_64-w64-mingw32-g++ -g ${INCLUDES} test.c -o bin/test_mingwxx && WINEDEBUG=-all wine ./bin/test_mingwxx.exe

printf "\nmingw-gcc:\n"
x86_64-w64-mingw32-gcc -g ${INCLUDES} test.c -o bin/test_mingw && WINEDEBUG=-all wine ./bin/test_mingw.exe

printf "\nmsvc c++14:\n"
cl.exe ${WINCLUDES} /std:c++14 test.cpp /link /OUT:bin/test_msvcxx.exe /SUBSYSTEM:CONSOLE && WINEDEBUG=-all wine ./bin/test_msvcxx.exe

printf "\nmsvc c17:\n"
cl.exe ${WINCLUDES} /std:c17 test.c /link /OUT:bin/test_msvc.exe /SUBSYSTEM:CONSOLE && WINEDEBUG=-all wine ./bin/test_msvc.exe

printf "\nclang-cl.exe c++11:\n"
clang-cl.exe /clang:--std=c++11  ${WINCLUDES} test.cpp /link /OUT:bin/test_clang-clxx.exe && WINEDEBUG=-all wine ./bin/test_clang-clxx.exe

printf "\nclang-cl.exe c17:\n"
clang-cl.exe /clang:--std=c17  ${WINCLUDES} test.c /link /OUT:bin/test_clang-cl.exe && WINEDEBUG=-all wine ./bin/test_clang-cl.exe

printf "\nclang.exe c99:\n"
clang.exe --std=c99 ${INCLUDES} test.c -o bin/test_clang.exe && WINEDEBUG=-all wine ./bin/test_clang.exe

printf "\nclang++.exe c++14:\n"
clang++.exe --std=c++14 ${INCLUDES} test.cpp -o bin/test_clangxx.exe && WINEDEBUG=-all wine ./bin/test_clangxx.exe

printf "\ntcc c99:\n"
tcc -g ${INCLUDES} test.c -o bin/test_tcc && ./bin/test_tcc

#printf "\ntcc.exe c99:\n" # TODO doesn't compile
#./tcc/tcc.exe -g ${INCLUDES} -I tcc/include test.c -o bin/test_tcc && ./bin/test_tcc

rm -f *.obj
rm -f *.pdb

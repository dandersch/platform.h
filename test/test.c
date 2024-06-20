#include "../platform.h"

#include <stdio.h>
int main(int argc, char** argv)
{
    /* TEST PLATFORM DETECTION */
    {
        printf("OS:...........%s\n", platform_os_string(platform_detect_os()));
        printf("COMPILER:.....%s\n", platform_compiler_string(platform_detect_compiler()));
        printf("ARCH:.........%s\n", ARCHITECTURE_STRING);
        printf("STANDARD:.....%s\n", C_STANDARD_STRING);
        printf("BUILD_TYPE:...%s\n", BUILD_TYPE_STRING);
    }

    /* TEST DEBUG FUNCTIONS */
    {
        STATIC_ASSERT((2+2==4), "All good");
        //STATIC_ASSERT((2+2==5), "ignorance is strength");

        //ASSERT(!debug_running_under_debugger()); /* NOTE: run in debugger to test this */

        ASSERT(1 == 1);
        //ASSERT(0 == 1);
    }

    /* TEST PRAGMAS */
    {
        /* Test if we can ignore warnings in a custom scope by pushing and popping */
        PUSH_WARNINGS()
        WARNING_TO_IGNORE("-Wshadow", 6244)
        WARNING_TO_IGNORE("-Wshadow", 6246)
        // no warning/error of shadowing a variable should pop up here
        int a = 0;
        {
                int a = 0;
        }

        #ifdef COMPILER_TCC
        #pragma pack(1) // NOTE: tcc doesnt support do_pragma's
        #endif
        PUSH_STRUCT_PACK(1)
        typedef struct test_align_packed
        {
            int   a; //   4B
            char  b; // + 1B
            float c; // + 4B
                     // = 9B because of packing
        } test_align_packed;
        POP_STRUCT_PACK()
        #ifdef COMPILER_TCC
        #pragma pack(8) // NOTE: tcc doesnt support do_pragma's
        #endif
        typedef struct test_align_unpacked
        {
            int   a; //    4B
            char  b; // +  1B
            float c; // +  4B
                     // = 12B bc of std alignment
        } test_align_unpacked;
        POP_WARNINGS()

        /* Test #pragma packing */
        ASSERT( 9 == sizeof(test_align_packed));
        ASSERT(12 == sizeof(test_align_unpacked));
    }

    /* TEST THREAD STUFF */
    {
        #if !defined(COMPILER_TCC) // TODO
        static thread_local u32 thread_thing = 0; // TODO test properly with threads
        #endif
    }

    /* TEST MEMORY MACROS */
    {
        typedef struct v3f { float x,y,z; } v3f;

        /* test offset of macro */
        u64 offset = OFFSET_OF(v3f, x);
        ASSERT(offset == 0);
        offset = OFFSET_OF(v3f, y);
        ASSERT(offset == 4);
    }

    /* TEST TYPE_OF(), SAME_TYPE(), CONTAINER_OF() */
    {
        #if defined(container_of)
          typedef struct test_t { int a; float b; } test_t;
          test_t test = { 2, 4.3f };
          float* ptr = &test.b;
          test_t* test_ptr = container_of(ptr, test_t, b);
          ASSERT(test_ptr == &test);
        #endif
    }

    return 0;
}


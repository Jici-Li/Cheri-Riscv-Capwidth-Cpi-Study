#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

int main(int argc, char **argv) {
    if (argc < 5) {
        printf("Usage: %s trace.txt work_kb width_bytes iters\n", argv[0]);
        return 1;
    }

    const char *trace_path = argv[1];
    int work_kb = atoi(argv[2]);       
    int width = atoi(argv[3]);             
    int iters = atoi(argv[4]);            
    if (work_kb <= 0 || iters <= 0) {
        printf("work_kb and iters must be > 0\n");
        return 1;
    }

    if (width != 8 && width != 16) {
        printf("Warning: width=%d, recommended: 8 or 16\n", width);
    }

    size_t work_size = (size_t)work_kb * 1024;
    volatile unsigned char *work = (volatile unsigned char *)malloc(work_size);

    if (work == NULL) {
        printf("malloc failed\n");
        return 1;
    }
    memset((void*)work, 1, work_size);

    unsigned long long checksum = 0;

    for (int t = 0; t < iters; t++) {
        FILE *fp = fopen(trace_path, "r");
        if (fp == NULL) {
            printf("cannot open trace file: %s\n", trace_path);
            free((void*)work);
            return 1;
        }

        char op;
        unsigned long long addr;

        while (fscanf(fp, " %c %llx", &op, &addr) == 2) {

            size_t base = (size_t)(addr % (work_size - 64));

            if (op == 'W') {
                for (int off = 0; off < width; off += 8) {
                    volatile uint64_t *p = (volatile uint64_t *)(work + base + off);
                    *p = *p + 1;
                }
            } else {
                for (int off = 0; off < width; off += 8) {
                    volatile uint64_t *p = (volatile uint64_t *)(work + base + off);
                    checksum += *p; 
                }
            }

            checksum += (addr ^ (unsigned long long)op);
        }

        fclose(fp);
    }
    printf("done. checksum=%llu work_kb=%d width=%d iters=%d\n",
           checksum, work_kb, width, iters);

    free((void*)work);
    return 0;
}

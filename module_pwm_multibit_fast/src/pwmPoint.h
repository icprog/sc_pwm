
struct pwmpoint {
    int time, value;
};

extern void mysort(struct pwmpoint points[]);
extern int makeAddress(unsigned int program[], unsigned int pc);

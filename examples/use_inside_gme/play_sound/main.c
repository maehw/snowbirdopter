typedef void code();
typedef int func();

void main(int *param_1)
{

    char (*isAudioPlaying)(void) = (void *)*(param_1 + 3);

    if (isAudioPlaying() == 0)
    {
        int offsetPointer34 = *(param_1 + 13);
        int someOffset = **(int **)(param_1 + 14);
        int var;
        int copyOfVar;
        int soundId;
        soundId = *(char *)(offsetPointer34 + 0x1320);
        // soundId = 42;

        (**(code **)(param_1 + 9))(someOffset, 4, 0);
        (**(code **)(param_1 + 6))(someOffset, &var, 4);
        (**(code **)(param_1 + 9))(someOffset, var + soundId * 8, 0);
        (**(code **)(param_1 + 6))(someOffset, &var, 4);
        copyOfVar = var;
        (**(code **)(param_1 + 6))(someOffset, &var, 4);
        (**(code **)(param_1 + 11))(**(int **)(param_1 + 14), copyOfVar, var);

        *(char *)(offsetPointer34 + 0x1320) = (*(char *)(offsetPointer34 + 0x1320)) + 1; // counts up 
    }
}
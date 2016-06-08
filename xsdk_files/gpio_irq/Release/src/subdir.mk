################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
LD_SRCS += \
../src/lscript.ld 

C_SRCS += \
../src/gpio_isr.c \
../src/platform.c 

OBJS += \
./src/gpio_isr.o \
./src/platform.o 

C_DEPS += \
./src/gpio_isr.d \
./src/platform.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM A53 gcc compiler'
	aarch64-none-elf-gcc -Wall -O2 -c -fmessage-length=0 -MT"$@" -I../../gpio_irq_bsp/psu_cortexa53_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '



#include <assert.h>
#include <print.h>
#include <stdlib.h>
#include <xs1.h>
#include "pwm_singlebit_port.h"

#define MAX_NUM_PORTS 16

#pragma unsafe arrays
void pwmSingleBitPort(
    chanend c, clock clk,
    out buffered port:32 p[],
    unsigned int numPorts,
    unsigned int resolution, 
    unsigned int timeStep,
    unsigned int edge) {

    timer t;
    unsigned int time;
    unsigned int dutyCycle[MAX_NUM_PORTS] = {0};
    unsigned int numTicks = 0;
    unsigned int value_te,value_le;

    // Calculates the timer period
    unsigned int period = (timeStep == 0) ? 32 : 32 * (timeStep * 2);

    assert(numPorts > 0);
    assert(numPorts <= MAX_NUM_PORTS);

    // Configures the port clocks.
    set_clock_div(clk, timeStep);
    for (unsigned int i = 0; i < numPorts; ++i) {
        set_port_clock(p[i], clk);
    }
    start_clock(clk);

    // Gets the initial time. 
    t :> time;
    time += period;

    while (1) {
        select {
        // A new set of duty cycle values are avaliable.
        #pragma xta endpoint "updateDutyCycle"
        case slave { 
            int i = 0;
            do { 
            	numTicks = 0;
                c :> dutyCycle[i];  
                ++i; 
            } while (i < numPorts);}:
            break;

        // Handles the pwm output.
        #pragma xta endpoint "handlePwm"
        case t when timerafter (time) :> void:
            if (numTicks == resolution)
                numTicks = 0;
            
            for (unsigned int i = 0; i < numPorts; ++i) {
                #pragma xta label "handlePwmLoop"
                unsigned int value = dutyCycle[i];


                if(edge == 1) {
                	if(value < numTicks){
                		p[i] <: 0x0;
                	} else if(value > (numTicks + 32)){
                		p[i] <: 0xffffffff;
                	} else{
                		p[i] <: ((1 << (value & 0x1f)) - 1);
                	}
                } else if(edge == 2){
                	value_te = resolution - value;
                	if(value_te > (numTicks + 32)){
                		p[i] <: 0x0;
                	} else if(value_te < numTicks){
                		p[i] <: 0xffffffff;
                	} else{
                		p[i] <: (0xffffffff << (value_te & 0x1f));
                	}
                }
                	else if(edge == 3){
                	value_le = (resolution + value)>>1;
                	value_te = (resolution - value)>>1;

                	if(value > 32) {
                		if (value_te > (numTicks + 32)){
                			p[i] <: 0x0;
                		} else if ((value_te > numTicks) & (value_te < (numTicks + 32))) {
               	    	 p[i] <: (0xffffffff << (value_te & 0x1f));
               	     }else if(value_le < numTicks){
            	    	 p[i] <: 0x0;
            	     }else if ((value_le > numTicks) & (value_le < (numTicks + 32))) {
            	    	 p[i] <: ((1 << (value & 0x1f)) - 1);
            	     }else {
            	    	 p[i] <: 0xffffffff;
            	     }
                    //end of 32
                	} else {
                	     if (((resolution>>1) > numTicks) & ((resolution>>1) < (numTicks + 32))) {
                	          p[i] <: (((1 << (value & 0x1f)) - 1) << (16 - (value>>1)));
                	     } else{
                	     p[i] <: 0x0;
                	     }
                	}


                }//end
            }
            numTicks += 32;
            time += period;
            break;
        }
    }
}

void pwmSingleBitPortSetDutyCycle(
    chanend c, 
    unsigned int dutyCycle[], 
    unsigned int numPorts) {

    assert(numPorts < MAX_NUM_PORTS);
    master {
        for (unsigned int i = 0; i < numPorts; ++i) {
            c <: dutyCycle[i];
        }
    }
}




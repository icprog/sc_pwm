/*
 * The copyrights, all other intellectual and industrial
 * property rights are retained by XMOS and/or its licensors.
 * Terms and conditions covering the use of this code can
 * be found in the Xmos End User License Agreement.
 *
 * Copyright XMOS Ltd 2010
 *
 * In the case where this code is a modification of existing code
 * under a separate license, the separate license terms are shown
 * below. The modifications to the code are still covered by the
 * copyright notice above.
 *
 **/

#include <xs1.h>

#ifdef __pwm_config_h_exists__
#include <pwm_config.h>
#endif

#include <pwm_service_inv.h>

void disable_fets(buffered out port:32 p_ifm_motor_hi[],  buffered out port:32 p_ifm_motor_lo[], char num_of_phases){

    p_ifm_motor_hi[0] <: 0;
    p_ifm_motor_hi[1] <: 0;
    p_ifm_motor_hi[2] <: 0;

    p_ifm_motor_lo[0] <: 0;
    p_ifm_motor_lo[1] <: 0;
    p_ifm_motor_lo[2] <: 0;

    if(num_of_phases > 3){

        p_ifm_motor_hi[3] <: 0;
        p_ifm_motor_lo[3] <: 0;
    }

    delay_milliseconds(1);
}

#if LOCK_ADC_TO_PWM

extern unsigned pwm_op_inv( unsigned buf, buffered out port:32 p_pwm[], buffered out port:32 (&?p_pwm_inv)[], chanend c, unsigned control, chanend c_trig, in port dummy_port );

static void do_pwm_port_config_inv_adc_trig( in port dummy, buffered out port:32 p_pwm[], buffered out port:32 (&?p_pwm_inv)[], clock clk )
{
	unsigned i;

	for (i = 0; i < PWM_CHAN_COUNT; i++)
	{
		configure_out_port(p_pwm[i], clk, 0);
		if (!isnull(p_pwm_inv)){
            configure_out_port(p_pwm_inv[i], clk, 0);
            set_port_inv(p_pwm_inv[i]);
		}
	}

	/* dummy port used to send ADC trigger */
	configure_in_port(dummy,clk);

	start_clock(clk);
}

void do_pwm_inv_triggered( chanend c_pwm, chanend c_adc_trig, in port dummy_port, buffered out port:32 p_pwm[], buffered out port:32 (&?p_pwm_inv)[], clock clk)
{

	unsigned buf, control;

	/* First read the shared memory buffer address from the client */
	c_pwm :> control;

	/* configure the ports */
	do_pwm_port_config_inv_adc_trig( dummy_port, p_pwm, p_pwm_inv, clk );

	/* wait for initial update */
	c_pwm :> buf;

	while (1)
	{
		buf = pwm_op_inv( buf, p_pwm, p_pwm_inv, c_pwm, control, c_adc_trig, dummy_port );
	}

}
#else

extern unsigned pwm_op_inv( unsigned buf, buffered out port:32 p_pwm[], buffered out port:32 (&?p_pwm_inv)[], chanend c, unsigned control );

static void do_pwm_port_config_inv(  buffered out port:32 p_pwm[], buffered out port:32 (&?p_pwm_inv)[], clock clk )
{
	unsigned i;

	for (i = 0; i < PWM_CHAN_COUNT; i++)
	{
		configure_out_port(p_pwm[i], clk, 0);
		if (!isnull(p_pwm_inv)){
            configure_out_port(p_pwm_inv[i], clk, 0);
            set_port_inv(p_pwm_inv[i]);
		}
	}

	start_clock(clk);
}

void do_pwm_inv( chanend c_pwm, buffered out port:32 p_pwm[],  buffered out port:32 (&?p_pwm_inv)[], clock clk)
{

	unsigned buf, control;

	/* First read the shared memory buffer address from the client */
	c_pwm :> control;

	/* configure the ports */
	do_pwm_port_config_inv( p_pwm, p_pwm_inv, clk);

	/* wait for initial update */
	c_pwm :> buf;

	while (1)
	{
		buf = pwm_op_inv( buf, p_pwm, p_pwm_inv, c_pwm, control );
	}

}
#endif

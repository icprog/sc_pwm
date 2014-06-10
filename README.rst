SOMANET Symmetrical PWM Software Component
.........................................
.. image:: https://s3-eu-west-1.amazonaws.com/synapticon-resources/images/logos/synapticon_fullname_blackoverwhite_280x48.png
.. image:: http://s27.postimg.org/higfoxmn7/xmos_logo_reduced.png

:Latest release: 1.0.1
:Maintainer: Synapticon GmbH
:Description: The Pulse Width Modulation(PWM) components generates a synatrical PWM signal.

Key Features
============

  * The components can be configured for Leading edge, Trailing edge and Center edge variations
  * Configurable timestep, resolution

Firmware Overview
=================

The components will run in a par with the following function which does not terminate. A single function starts the pwm server and passes it a channel with 
which it will communicate with the client, a clock block required for the clocking of the required ports, an array of ports on which the pwm signals will be generated, and the number of ports in the array. 

Known Issues
============

none

Required software (dependencies)
================================

  * None

License
=======

Please see `LICENSE`_.


.. _LICENSE: https://github.com/synapticon/sc_pwm/blob/master/LICENSE.dox

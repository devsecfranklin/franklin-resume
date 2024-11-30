# C++ Code

- [How to program the ATtiny 841 using the Arduino IDE](https://www.youtube.com/watch?v=TyJQtaTvj3Q)
- [ATTinyCore Universal](https://github.com/SpenceKonde/ATTinyCore)
- [I2C Device Library](http://www.i2cdevlib.com/)

## ATTiny841

- 8k Flash, 512b EEPROM, 512b SRAM
- Optiboot bootloader support - program over serial! (takes a bit more memory)
- Dual hardware UARTs
- Hardware SPI
- Hardware I2C slave (I2C master is handled with a software implementation)
- SIX PWM outputs
- ADC on all pins
- Two on-chip analog comparators
- Compatible with Arduino IDE 1.6.5 and higher - we recommend the latest 1.8.x release.
- 8mhz (internal), up to 16mhz with external crystal. (20mhz seems to work @ 5v and room temperature, despite being out of spec)

## MPU6050

- [Arduino and MPU6050 Accelerometer and Gyroscope Tutorial](https://howtomechatronics.com/tutorials/arduino/arduino-and-mpu6050-accelerometer-and-gyroscope-tutorial/)
- [How to Interface Arduino and the MPU 6050 Sensor](https://maker.pro/arduino/tutorial/how-to-interface-arduino-and-the-mpu-6050-sensor)

### How Does IMU Interfacing Work?

IMU (inertia measurement unit) sensors usually consist of two or more
parts. Listing them by priority, they
are the accelerometer, gyroscope, magnetometer, and altimeter. The MPU 6050 is a
6 DOF (degrees of freedom) or a six-axis IMU sensor, which means that it gives
six values as output: three values from the accelerometer and three from the
gyroscope. The MPU 6050 is a sensor based on MEMS (micro electro mechanical
systems) technology. Both the accelerometer and the gyroscope are embedded inside a
single chip. This chip uses I2C (inter-integrated circuit) protocol for communication.

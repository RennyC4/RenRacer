//+------+
//|Math  |
//+------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Scratch                                      Http://www.admdev.com/scratch |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
//| Math Functions are stored here.                                            |
//+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+

/*
 * wrap
 *
 * Limits the given value to the given range and will wrap the value to the
 * the other end of the range if exceeded.
 *
 * value: A number
 *
 * minValue: The minimum value of the range
 *
 * maxValue: The maximum value of the range
 *
 * Returns: A number within the given range.
 */
 
float(float a, float b) mod;
float(float value, float minValue, float maxValue) wrap =
{
    local float range = maxValue - minValue;
    return mod(value - minValue, range + 1) + minValue;
};

/*
 * sign
 *
 * Returns an indication of the sign of the given number.
 *
 * x: A number
 *
 * Returns: -1 if x < 0, 0 if x == 0, 1 if x > 0.
 */
 
float(float x) sign =
{
    if (x > 0)
        return 1;
    else if (x < 0)
        return -1;
    return 0;
};
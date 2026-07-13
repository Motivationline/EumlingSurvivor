/** Noise texture defining the wind pattern. */
global uniform sampler2D wind_noise;

/** Spatial scale of the wind pattern, i.e. how quickly it varies over space. */
global uniform float wind_frequency;

/** Speed at which the wind pattern moves. */
global uniform float wind_speed;

/** Strength of the foliage displacement. */
global uniform float wind_strength;

/** Direction the wind blows. */
global uniform vec3 wind_direction;
shader_type canvas_item;
uniform vec4 hitFlashColor : source_color = vec4(1,1,1,1);
uniform bool enabled = false;

void fragment() {
	vec4 spriteColor = texture(TEXTURE,UV);
	vec3 finalRGB = enabled ? hitFlashColor.rgb : spriteColor.rgb;
	COLOR = vec4(finalRGB,spriteColor.a);
	}

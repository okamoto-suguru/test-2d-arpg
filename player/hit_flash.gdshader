shader_type canvas_item;

uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float flash_modifier : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	// 元のテクスチャの色（透明度も含む）を取得
	vec4 original_color = texture(TEXTURE, UV);
	
	// 色(RGB)だけをフラッシュの色と混ぜ合わせる
	vec3 mixed_rgb = mix(original_color.rgb, flash_color.rgb, flash_modifier);
	
	// 最終的な色は、混ぜ合わせた色(RGB)と、「元の透明度(a)」を組み合わせる
	COLOR = vec4(mixed_rgb, original_color.a);
}
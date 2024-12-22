shader_type canvas_item;

uniform sampler2D mask_texture; // Texture de masque à fournir
uniform vec2 mask_position;
uniform vec2 mask_size;

void fragment() {
    // Charger la couleur du masque
    vec2 mask_uv = (UV - mask_position) / mask_size;
    vec4 mask = texture(mask_texture, mask_uv);

    // Charger la couleur de l'objet
    vec4 object_color = texture(TEXTURE, UV);

    // Mélanger en fonction de l'alpha du masque
    COLOR = vec4(object_color.rgb, object_color.a * mask.r); // Utilise le canal rouge du masque
}

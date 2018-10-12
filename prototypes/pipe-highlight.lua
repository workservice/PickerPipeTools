local merge = _G.util.merge

data:extend {
    merge {
        data.raw['corpse']['wall-remnants'],
        {
            name = 'picker-pipe-marker-box-good',
            icon = '__PickerPipeTools__/graphics/entity/markers/32x32highlighter.png',
            time_before_removed = 60 * 20,
            collision_box = {{0, 0}, {0, 0}},
            final_render_layer = 'selection-box',
            animation = {
                width = 64,
                height = 64,
                frame_count = 1,
                direction_count = 1,
                scale = 0.5,
                shift = {-0.5, -0.5},
                filename = '__PickerPipeTools__/graphics/entity/markers/32x32highlighter.png'
            }
        }
    },
    merge {
        data.raw['corpse']['wall-remnants'],
        {
            name = 'picker-pipe-marker-box-bad',
            icon = '__PickerPipeTools__/graphics/entity/markers/32x32highlighterbad.png',
            time_before_removed = 60 * 20,
            collision_box = {{0, 0}, {0, 0}},
            final_render_layer = 'selection-box',
            animation = {
                width = 64,
                height = 64,
                frame_count = 1,
                direction_count = 1,
                scale = 0.5,
                shift = {-0.5, -0.5},
                filename = '__PickerPipeTools__/graphics/entity/markers/32x32highlighterbad.png'
            }
        }
    },
    merge {
        data.raw['corpse']['wall-remnants'],
        {
            name = 'picker-underground-pipe-marker-horizontal',
            icon = '__PickerPipeTools__/graphics/entity/markers/underground-lines-single-horizontal.png',
            time_before_removed = 60 * 20,
            collision_box = {{0, 0}, {0, 0}},
            final_render_layer = 'selection-box',
            animation = {
                width = 64,
                height = 64,
                frame_count = 1,
                direction_count = 1,
                scale = 0.5,
                shift = {-0.5, -0.5},
                filename = '__PickerPipeTools__/graphics/entity/markers/underground-lines-single-horizontal.png'
            }
        }
    },
    merge {
        data.raw['corpse']['wall-remnants'],
        {
            name = 'picker-underground-pipe-marker-vertical',
            icon = '__PickerPipeTools__/graphics/entity/markers/underground-lines-single-vertical.png',
            time_before_removed = 60 * 20,
            collision_box = {{0, 0}, {0, 0}},
            final_render_layer = 'selection-box',
            animation = {
                width = 64,
                height = 64,
                frame_count = 1,
                direction_count = 1,
                scale = 0.5,
                shift = {-0.5, -0.5},
                filename = '__PickerPipeTools__/graphics/entity/markers/underground-lines-single-vertical.png'
            }
        }
    }
}

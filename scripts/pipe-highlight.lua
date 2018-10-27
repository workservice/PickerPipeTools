-------------------------------------------------------------------------------
--[ Pipe Highlighter ] -- Concept designed and code written by TheStaplergun (staplergun on mod portal) revised by Nexela
-------------------------------------------------------------------------------

local Player = require('lib/player')
local Event = require('lib/event')

local pipe_connections = {}
local function load_pipe_connections()
    if remote.interfaces['underground-pipe-pack'] then
        pipe_connections = remote.call('underground-pipe-pack', 'get_pipe_table')
    end
end
Event.register({Event.core_events.init, Event.core_events.load}, load_pipe_connections)

local function show_underground_sprites(event)
    local player = game.players[event.player_index]
    local filter = {
        area = {{player.position.x - 80, player.position.y - 50}, {player.position.x + 80, player.position.y + 50}},
        type = {'pipe-to-ground', 'pump'},
        force = player.force
    }
    for _, entity in pairs(player.surface.find_entities_filtered(filter)) do
        if entity.type == 'pipe-to-ground' or (entity.type == 'pump' and entity.name == 'underground-mini-pump') then
            local maxNeighbors = pipe_connections[entity.name] or 2
            for _, entities in pairs(entity.neighbours) do
                local neighbour_count = #entities
                for _, neighbour in pairs(entities) do
                    if neighbour.type == 'pipe-to-ground' or (neighbour.type == 'pump' and neighbour.name == 'underground-mini-pump') then
                        if (entity.position.x - neighbour.position.x) < -1.5 then
                            local distancex = neighbour.position.x - entity.position.x
                            for i = 1, distancex - 1, 1 do
                                player.surface.create_entity {
                                    name = 'picker-underground-pipe-marker-horizontal',
                                    position = {entity.position.x + i, entity.position.y}
                                }
                            end
                        end
                        if (entity.position.y - neighbour.position.y) < -1.5 then
                            local distancey = neighbour.position.y - entity.position.y
                            for i = 1, distancey - 1, 1 do
                                player.surface.create_entity {
                                    name = 'picker-underground-pipe-marker-vertical',
                                    position = {entity.position.x, entity.position.y + i}
                                }
                            end
                        end
                    end
                end
                if (maxNeighbors == neighbour_count) then
                    entity.surface.create_entity {
                        name = 'picker-pipe-marker-box-good',
                        position = entity.position
                    }
                elseif (neighbour_count < maxNeighbors) then
                    entity.surface.create_entity {
                        name = 'picker-pipe-marker-box-bad',
                        position = entity.position
                    }
                end
            end
        end
    end
end
Event.register('picker-show-underground-paths', show_underground_sprites)
--? Working on the recursive check.

local function getEW(deltaX)
    return deltaX > 0 and defines.direction.west or defines.direction.east
end

local function getNS(deltaY)
    return deltaY > 0 and defines.direction.north or defines.direction.south
end

local function get_direction(entity, neighbour)
    if not entity.valid or not neighbour.valid then
        return
    end
    local deltaX = entity.position.x - neighbour.position.x
    local deltaY = entity.position.y - neighbour.position.y
    if deltaX ~= 0 and deltaY == 0 then
        return getEW(deltaX)
    elseif deltaX == 0 and deltaY ~= 0 then
        return getNS(deltaY)
    elseif deltaX ~= 0 and deltaY ~= 0 then
        if math.abs(deltaX) > math.abs(deltaY) then
            return getEW(deltaX)
        elseif math.abs(deltaX) < math.abs(deltaY) then
            return getNS(deltaY)
        end
    end
end

local allowed_types =
{
    ["pipe"] = true,
    ["pipe-to-ground"] = true,
    ["pump"] = true
}
local pipe_highlight_marker = {
    [defines.direction.north] = 'picker-pipe-marker-ns',
    [defines.direction.east] = 'picker-pipe-marker-ew',
    [defines.direction.west] = 'picker-pipe-marker-ew',
    [defines.direction.south] = 'picker-pipe-marker-ns',
}
local pipe_highlight_marker_good = {
    [defines.direction.north] = 'picker-pipe-marker-good-ns',
    [defines.direction.east] = 'picker-pipe-marker-good-ew',
    [defines.direction.west] = 'picker-pipe-marker-good-ew',
    [defines.direction.south] = 'picker-pipe-marker-good-ns',
}
local function draw_underground_sprites(entity, neighbour)
    local entity_position = entity.position
    local neighbour_position = neighbour.position
    local delta_x = entity_position.x - neighbour_position.x
    local delta_y = entity_position.y - neighbour_position.y
    if delta_x < -1.5 then
        local distance_x = neighbour_position.x - entity_position.x
        for i = 1, distance_x - 1, 1 do
            entity.surface.create_entity {
                name = 'picker-underground-pipe-marker-horizontal',
                position = {entity_position.x + i, entity_position.y}
            }
        end
    elseif delta_x > 1.5 then
        for i = 1, delta_x - 1, 1 do
            entity.surface.create_entity {
                name = 'picker-underground-pipe-marker-horizontal',
                position = {entity_position.x - i, entity_position.y}
            }
        end
    elseif delta_y < -1.5 then
        local distance_y = neighbour_position.y - entity_position.y
        for i = 1, distance_y - 1, 1 do
            entity.surface.create_entity {
                name = 'picker-underground-pipe-marker-vertical',
                position = {entity_position.x, entity_position.y + i}
            }
        end
    elseif delta_y > 1.5 then
        for i = 1, delta_y - 1, 1 do
            entity.surface.create_entity {
                name = 'picker-underground-pipe-marker-vertical',
                position = {entity_position.x, entity_position.y - i}
            }
        end
    end
end

local function shift_in_direction(current_direction, position, distance_to_shift)
    if current_direction == defines.direction.north then
        return {position.x, position.y - distance_to_shift}
    elseif current_direction == defines.direction.east then
        return {position.x + distance_to_shift, position.y}
    elseif current_direction == defines.direction.west then
        return {position.x - distance_to_shift, position.y}
    elseif current_direction == defines.direction.south then
        return {position.x, position.y + distance_to_shift}
    end
end

local function highlight_pipeline(event)
    local player, _ = Player.get(event.player_index)
    local selection = player.selected
    if selection and allowed_types[selection.type] then

        local tracked_entities = {[selection.unit_number] = true}
        local orphan_counter = 0
        local args = {position = {}}
        local function recurse_pipeline(entity)
            local entity_position = entity.position
            for _ , entities in pairs(entity.neighbours) do
                local neighbour_count = #entities
                for _, neighbour in pairs(entities) do
                    local current_direction = get_direction(entity, neighbour)
                    local neighbour_type = neighbour.type
                    local neighbour_unit_number = neighbour.unit_number
                    local max_neighbours = pipe_connections[entity.name] or 2
                    if (neighbour_count < 2 and entity.type == 'pipe') or (neighbour_count < max_neighbours) then
                        entity.surface.create_entity {
                            name = 'picker-pipe-marker-box-bad',
                            position = entity_position
                        }
                        orphan_counter = orphan_counter + 1
                    end
                    if allowed_types[neighbour_type] and not tracked_entities[neighbour_unit_number] then
                        tracked_entities[neighbour_unit_number] = true
                        if entity.type == 'pipe-to-ground' and neighbour_type == 'pipe-to-ground' or (neighbour_type == 'pump' and neighbour.name == 'underground-mini-pump') then
                            draw_underground_sprites(entity, neighbour)
                        else
                            local neighbour_position = neighbour.position
                            args.position[1] = (entity_position.x + neighbour_position.x)/2
                            args.position[2] = (entity_position.y + neighbour_position.y)/2
                            args.name = pipe_highlight_marker[current_direction]
                            entity.surface.create_entity(args)
                        end
                        recurse_pipeline(neighbour)
                    elseif not allowed_types[neighbour_type] then
                        local position_to_place = shift_in_direction(current_direction, entity_position, 0.5)
                        args.position = position_to_place
                        args.name = pipe_highlight_marker_good[current_direction]
                        entity.surface.create_entity(args)
                    end
                end
            end
        end
        recurse_pipeline(selection)
        if orphan_counter > 0 then
            game.print(orphan_counter .. " dead end pipes detected")
        end
    end
end
Event.register('picker-highlight-pipeline', highlight_pipeline)

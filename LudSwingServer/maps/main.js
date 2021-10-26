const Map = require('../internal/concepts/map.js');

module.exports = new Map({
    name: 'Main Map',
    room_name: 'rLevel',
    description: '',

    mode: 'mmo',
    start_pos: [
        {x: 320, y: 3520}
    ],
    max_players: 99
})
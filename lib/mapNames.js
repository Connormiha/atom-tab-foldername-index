
let mapNames = {};
const handles = new Set();
const realTimeout = window.setTimeout;
const realClearTimeout = window.clearTimeout;
let timeoutId;

function execHandles(name) {
    for (const item of handles) {
        item(name);
    }
}

module.exports = {
    clear() {
        mapNames = {};
    },

    add(name) {
        if (mapNames[name]) {
            mapNames[name]++;
            realClearTimeout(timeoutId);
            timeoutId = realTimeout(() => execHandles(name));
        } else {
            mapNames[name] = 1;
        }
    },

    remove(name) {
        if (mapNames[name]) {
            if (mapNames[name] > 1) {
                realClearTimeout(timeoutId);
                timeoutId = realTimeout(() => execHandles(name));
            }

            if (mapNames[name] === 1) {
                delete mapNames[name];
            } else {
                mapNames[name]--;
            }
        }
    },

    addListener(callback) {
        handles.add(callback);
    },

    removeListener(callback) {
        handles.delete(callback);
    },

    hasReapeatedNames(name) {
        return !!mapNames[name] && mapNames[name] > 1;
    }
};

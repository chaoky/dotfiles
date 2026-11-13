import Clutter from 'gi://Clutter';

import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';

export default class GameLock extends Extension {
    enable() {
        // Returning true makes mutter act as if the binding didn't exist.
        this._filterId = global.window_manager.connect('filter-keybinding', (_wm, binding) =>
            !!global.display.focus_window?.is_fullscreen() &&
            (binding.get_name() === 'overlay-key' ||
             (binding.get_modifiers() & Clutter.ModifierType.SUPER_MASK) !== 0));
    }

    disable() {
        global.window_manager.disconnect(this._filterId);
    }
}

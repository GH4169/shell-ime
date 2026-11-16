globalThis.__shellIme = (() => {
  const states = new WeakMap(),
    instances = new WeakMap(),
    saved = new WeakMap();
  let held = null;
  function restore() {
    if (held) {
      held.readOnly = saved.get(held) ?? false;
      saved.delete(held);
      held = null;
    }
  }
  function update() {
    const input = document.activeElement,
      terminal = input?.closest?.('.xterm');
    if (
      !document.hasFocus() ||
      !terminal ||
      !input.matches('textarea.xterm-helper-textarea') ||
      !states.get(terminal)
    ) {
      restore();
      return;
    }
    if (held !== input) {
      restore();
      saved.set(input, input.readOnly);
      held = input;
    }
    input.readOnly = true;
  }
  document.addEventListener('focusin', update, true);
  document.addEventListener('focusout', () => queueMicrotask(update), true);
  window.addEventListener('blur', restore);
  document.addEventListener(
    'keydown',
    (event) => {
      update();
      if (
        !held ||
        event.target !== held ||
        event.key.length !== 1 ||
        event.key.charCodeAt(0) > 127 ||
        event.ctrlKey ||
        event.altKey ||
        event.metaKey ||
        event.isComposing
      )
        return;
      const terminal = instances.get(held.closest('.xterm'));
      if (!terminal) return;
      event.preventDefault();
      event.stopImmediatePropagation();
      terminal.input(event.key, true);
    },
    true
  );
  document.addEventListener(
    'paste',
    (event) => {
      update();
      if (!held || event.target !== held) return;
      const terminal = instances.get(held.closest('.xterm')),
        text = event.clipboardData?.getData('text/plain');
      if (terminal && text !== undefined) {
        event.preventDefault();
        event.stopImmediatePropagation();
        terminal.paste(text);
      }
    },
    true
  );
  return {
    attach(terminal) {
      terminal.parser.registerOscHandler(777, (value) => {
        if (!/^shell-ime;[01]$/.test(value)) return false;
        const element = terminal.element;
        if (element) {
          instances.set(element, terminal);
          states.set(element, value === 'shell-ime;1');
          update();
        }
        return true;
      });
    },
    restore,
    update,
  };
})();

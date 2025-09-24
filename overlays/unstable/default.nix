# Temporary overlay for unstable packages.
{ channels, ... }: final: prev: {
  vimPlugins = prev.vimPlugins // {
    inherit (channels.unstable.vimPlugins)
      codecompanion-nvim;
  };
}

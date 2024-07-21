return {
  -- add nord
  { "shaunsingh/nord.nvim" },
  -- add gruvbox
  { "ellisonleao/gruvbox.nvim" },
  -- Configure LazyVim to load nord
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}

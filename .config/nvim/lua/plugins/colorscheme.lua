return {
  -- add gruvbox
  { "ellisonleao/gruvbox.nvim" },
  { "aliqyan-21/darkvoid.nvim" },
  { "olivercederborg/poimandres.nvim" },
  { "nyoom-engineering/oxocarbon.nvim" },
  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "oxocarbon",
    },
  },
}

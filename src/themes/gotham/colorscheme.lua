return {
  { 'https://gitlab.com/shmerl/neogotham.git',
    lazy = false, -- to make sure it's loaded on startup
    priority = 1000, -- to load before other plugins
    config = function()
      vim.cmd.colorscheme("neogotham")
    end
  }
}

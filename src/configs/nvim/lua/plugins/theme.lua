return {
	{
   'https://gitlab.com/shmerl/neogotham.git',
    lazy = false,
    priority = 1000,
	  config = function()
      vim.cmd.colorscheme("neogotham")
    end,
  },
}

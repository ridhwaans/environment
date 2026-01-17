return {
        { "nvim-treesitter/playground", cmd = "TSPlaygroundToggle" },
        {
                "nvim-treesitter/nvim-treesitter",
                build = ":TSUpdate",
                opts = {
                        ensure_installed = {
                                "cmake",
                                "cpp",
                                "css",
                                "gitignore",
                                "go",
                                "graphql",
                                "http",
                                "java",
                                "scss",
                                "sql"
                        },

                        query_linter = {
                                enable = true,
                        },
                },
        config = function(_, opts)
                local TS = require("nvim-treesitter")
                TS.setup(opts)

                vim.filetype.add({
                        extension = {
                                mdx = "MDX",
                        },
                })
                vim.treesitter.language.register("markdown", "mdx")
        end,
        },
}

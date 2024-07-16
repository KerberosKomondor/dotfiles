return {
  {
    "vuki656/package-info.nvim",
    opts = {
      package_manager = "npm",
      hide_unstable_versions = true,
    },
    keys = {

      {
        "<LEADER>ns",
        function()
          require("package-info").show()
        end,
        desc = "Show Dependency Versions",
      },
      {
        "<LEADER>nc",
        function()
          require("package-info").hide()
        end,
        desc = "Hide Dependency Versions",
      },
      {
        "<LEADER>nt",
        function()
          require("package-info").toggle()
        end,
        desc = "Toggle Dependency Versions",
      },
      {
        "<LEADER>nu",
        function()
          require("package-info").update()
        end,
        desc = "Update Current Dependency",
      },
      {
        "<LEADER>nd",
        function()
          require("package-info").delete()
        end,
        desc = "Delete Current Dependency",
      },
      {
        "<LEADER>ni",
        function()
          require("package-info").install()
        end,
        desc = "Install Dependency",
      },
      {
        "<LEADER>np",
        function()
          require("package-info").show()
        end,
        desc = "Change Dependency Version",
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      extensions = {
        package_info = {
          theme = "ivy",
        },
      },
    },
    config = function()
      require("telescope").load_extension("package_info")
    end,
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>n", group = "npm" },
      },
    },
  },
}

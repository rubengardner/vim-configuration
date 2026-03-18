return {
  "milanglacier/minuet-ai.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    provider = "openai_fim_compatible",
    provider_options = {
      openai_fim_compatible = {
        api_key = "TERM",
        name = "Ollama",
        end_point = "http://localhost:11434/v1/completions",
        model = "qwen2.5-coder:1.5b",
        optional = {
          max_tokens = 256,
          top_p = 0.9,
        },
      },
    },
  },
  config = function(_, opts)
    require("minuet").setup(opts)
    require("blink.cmp").add_provider("minuet", {
      name = "minuet",
      module = "minuet.blink",
      score_offset = 8,
    })
  end,
}

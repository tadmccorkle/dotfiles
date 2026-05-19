require("luasnip.session.snippet_collection").clear_snippets("c")

local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local rep = require("luasnip.extras").rep
local fmta = require("luasnip.extras.fmt").fmta

ls.add_snippets("c", {
	s(
		"$ig",
		fmta(
			[[
			#ifndef <>_H
			#define <>_H

			<>

			#endif // <>_H
			]],
			{ i(1), rep(1), i(0), rep(1) }
		)
	),
	s(
		"$tde",
		fmta(
			[[
			typedef enum
			{
				<>_<>,
			} <>;
			]],
			{ rep(1), i(2), i(1) }
		)
	),
	s(
		"$tdec",
		fmta(
			[[
			typedef enum
			{
				<>_<>,
				<>_COUNT,
			} <>;
			]],
			{ rep(1), i(2), rep(1), i(1) }
		)
	),
	s(
		"$tds",
		fmta(
			[[
			typedef struct <> <>;
			struct <>
			{
				<>
			};
			]],
			{ rep(1), rep(1), i(1), i(2) },
			{ indent_string = "  " }
		)
	),
})

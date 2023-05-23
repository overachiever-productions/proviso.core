Set-StrictMode -Version 1.0;

<#
	Custom Formats / Output. 
		old proviso was a bit of a mess here... too visually ... busy. 

		I can simplify that here by 2 main techniques: 
			1. simplified/cohesive vision - with fewer columns in the output... 
			2. color. 


		In terms of color. 
			Here's a description/pic of how it looks: https://jdhitsolutions.com/blog/powershell/7899/color-my-powershell-world/ 
			And here's the code / implementation: 
				https://github.com/jdhitsolutions/PSScriptTools/blob/master/formats/filesystem-ansi.format.ps1xml
				Specifically, not the ScriptBlock for the FILENAME... 
					
					this very SMARTLY checks to see what kind of 'console' the host is ... 
							and, if it's one that won't work with color, doesn't bother to output the filename in color (i.e., just spits out $file at the bottom). 

					Otherwise it's looking up data against a json file: 
						https://github.com/jdhitsolutions/PSScriptTools/blob/master/psansifilemap.json

					Which... wow. that's insane. 
						but... thos are ANSI escape code sequences... 
						and, they're DOPE. (ugly af but dope). 
							cuz not only do they allow for text colorization (easily enough)
							but they also allow for BACKGROUND colors... 
							they're complex/versatile. 
								big time. 

					2 bits of fodder: 
						https://treit.github.io/powershell/2019/02/11/ATouchOfColor.html
						http://www.lihaoyi.com/post/BuildyourownCommandLinewithANSIescapecodes.html

				I don't need anything super complex here. 
					i.e., I think my new format/table will show: 
						
						name/display-name				Expected 		Actual 			Notes/Erorrs/Whatzit. 
					
					
					with modifications in the form of: 
						READ operations will omit the EXPECTED column and only show Actual. 
						INVOKE MIGHT have/inject an 'Initial' column between Expected and Actual and/or might change 'Actual' (or Result?) to ... something like 'Final'. 

						Either way, for both Test and Invoke operations
							- anything that matches/passes the test and/or configuration will be simple GREEN text on the 'Actual' (or Result - not sure which of those 2 i'll call it). 
									OR, possibly: green background with WHITE text. 
							- anything that does NOT match ... will be in RED text and bold? 
									OR, possibly: red background with black (or white?) text? 

							- Errors/exceptions/etc. will probably be red/yellow text. 


					and, of course, just 'wrap' all of the above into a func (like i did with monolithic proviso) - and just pass in the 'data' to this func/etc. 

#>


$global:PvFormatter = [Proviso.Core.Formatter]::Instance;

# TODO: execute something like $PvFormatter.SetCurrentHostDetails(blah)
# 			where the idea is I set info about what kind of formatting/output the current output/console can handle... 
# 			so, that when I call $PvFormatter.OutputTestValue(or, whatever) ... it can check for support of current host for color and such... 
# Copyright 2013, Michael Pacchioli.
#  
# This file is part of QuoteCombo.
# 
# QuoteCombo is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 3,
# as published by the Free Software Foundation.
# 
# QuoteCombo is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with QuoteCombo.  If not, see <http://www.gnu.org/licenses/>.


alphabet = [
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
	'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
]


# modified from www.netlobo.com/url_query_string_javascript.html

getURLParameter = (name) ->
	name = name.replace(/[\[]/, '\\\[').replace(/[\]]/, '\\\]')

	regexS = '[\\?&]' + name + '=([^&#]*)'
	regex = new RegExp regexS
    
	results = regex.exec window.location.href
    
	if results == null
		return ''
	else
		return results[1]


# from https://gist.github.com/ddgromit/859699

shuffle = (a) ->
	for i in [(a.length - 1)..1]
		j = Math.floor Math.random() * (i + 1)
		[a[i], a[j]] = [a[j], a[i]]
		
	a


makePuzzle = () ->
	lettersPerGroup = 2
	sort = true
	showSpaces = true
	
	lettersParam = parseInt getURLParameter 'letters', 10

	if lettersParam and lettersParam > 0 and lettersParam <= 5
		lettersPerGroup = lettersParam

	if (getURLParameter 'sort').toLowerCase() == 'true'
		sort = true
	
	if (getURLParameter 'sort').toLowerCase() == 'false'
		sort = false

	if (getURLParameter 'spaces').toLowerCase() == 'true'
		showSpaces = true
	
	if (getURLParameter 'spaces').toLowerCase() == 'false'
		showSpaces = false

	randQuoteIndex = Math.floor(Math.random() * quotes.length)

	quote = quotes[randQuoteIndex][0]
	quoteCapitalized = quote.toUpperCase()
	
	quoteNorm = quoteCapitalized.replace /[^A-Z]+/g, ' '
	quoteCheck = quoteCapitalized.replace /[^A-Za-z]/g, ''

	attribution = quotes[randQuoteIndex][1]

	($ '#quote').html quote
	($ '#attribution').html '- ' + attribution

	return drawPuzzle(
		quote, quoteNorm, quoteCheck,
		attribution, lettersPerGroup, sort,
		showSpaces
	)


drawPuzzle = (
	quote, quoteNorm, quoteCheck,
	attribution, lettersPerGroup, sort,
	showSpaces
) ->
	
	numLetters = 0

	if showSpaces
		quoteToDisplay = quoteNorm
	else
		quoteToDisplay = quoteCheck

	for char in quoteToDisplay.split ''
		if char != ' '
			numLetters++
			letterGroup = [char]

			tempAlphabet = alphabet.slice(0)
			
			tempIndex = tempAlphabet.indexOf char
			tempAlphabet.splice tempIndex, 1

			for i in [1..(lettersPerGroup - 1)]
				tempLength = tempAlphabet.length
				tempIndex = Math.floor(Math.random() * tempLength)
				
				letterGroup.push tempAlphabet[tempIndex]
				tempAlphabet.splice tempIndex, 1

			if sort == true
				letterGroup.sort()
			else
				letterGroup = shuffle(letterGroup)

			groupHTML = '<div class="group" id="group-' + numLetters + '">'
 
			groupHTML += (
				'<table>' +
				'<tr>'
			)

			for letter, i in letterGroup
				j = i + 1

				groupHTML += (
					'<td>' +
					'<span ' +
					'class="letter" ' +
					'id="letter-' +
					numLetters +
					'-' +
					j +
					'">' +
			 		letter + 
			 		'</span>' +
			 		'</td>'
			 	)

			groupHTML += '</tr>'
			groupHTML += '<tr>'

			for letter, i in letterGroup
				j = i + 1
				
				groupHTML += (
					'<td>' +
					'<input ' +
					'id="input-' + 
					numLetters +
					'-' +
					j +
					'" ' +					
					'name="letter-' +
					numLetters + 
					'" ' +
					'type="radio" ' +
					'value="' +
					letter +
					'" ' +
					'style="margin-top:0px;" ' +
					'/>' +
					'</td>'
				)

			groupHTML += '</tr>'

			groupHTML += (
				'</table>' +
				'</div>'
			)
		else if showSpaces
			groupHTML = (
				'<div class="clear"></div>' +
				'<div class="vertical-space"></div>'
			)

		($ '#puzzle').append groupHTML

	return [quote, quoteNorm, quoteCheck, attribution, lettersPerGroup, numLetters]


checkGame = (quoteCheck, numLetters) ->
	testQuote = ''

	for i in [1..numLetters]
		letterButton = $ 'input:radio[name=letter-' + i + ']:checked'
		letter = letterButton.val()

		if letter
		 	testQuote += letter

	if testQuote == quoteCheck
		$('#quote-modal').modal('show');


$ ->
	result = makePuzzle()
	
	quote = result[0]
	quoteNorm = result[1]
	quoteCheck = result[2]
	attribution = result[3]
	lettersPerGroup = result[4]
	numLetters = result[5]

	($ '.group').click (event) ->
		inputID = event.target.id
		
		parts = inputID.split '-'
		
		group = parts[1]
		groupLetter = parts[2]
		
		for i in [1..5]
			letterID = '#letter-' + group + '-' + i
			($ letterID).css 'color', '#CCCCCC'
		
		letterID = '#letter-' + group + '-' + groupLetter
		($ letterID).css 'color', '#000000'
		
		checkGame quoteCheck, numLetters

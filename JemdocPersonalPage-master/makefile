all : index.html personal/index.html teaching/index.html \
  trivia/index.html software/index.html consulting/index.html \
  research/index.html

index.html : MENU ./index.jemdoc
	jemdoc index.jemdoc

research/index.html : MENU ./research/index.jemdoc
	jemdoc ./research/index.jemdoc

trivia/index.html : MENU ./trivia/index.jemdoc
	jemdoc ./trivia/index.jemdoc

software/index.html : MENU ./software/index.jemdoc
	jemdoc ./software/index.jemdoc

consulting/index.html : MENU ./consulting/index.jemdoc
	jemdoc ./consulting/index.jemdoc

personal/index.html : MENU ./personal/index.jemdoc
	jemdoc ./personal/index.jemdoc

teaching/index.html : MENU ./teaching/index.jemdoc teaching/stats406/index.html teaching/stats414/index.html
	jemdoc ./teaching/index.jemdoc

teaching/stats406/index.html : MENU ./teaching/stats406/index.jemdoc
	jemdoc ./teaching/stats406/index.jemdoc

teaching/stats414/index.html : MENU ./teaching/stats414/index.jemdoc
	jemdoc ./teaching/stats414/index.jemdoc


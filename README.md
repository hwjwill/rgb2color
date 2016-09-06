# rgb2color
Convert images in R, G, B channels from the Prokudin-Gorskii photo collection into a colored image. Auto aligned using NCC and customized image pyramid. In picture below, the three gray images represents Blue, Green, and Red channels from top to bottom. This project’s purpose is to create colored image automatically on the left. Fore more results: http://inst.eecs.berkeley.edu/~cs194-26/fa16/upload/files/proj1/cs194-26-acm/

![Example](http://imgur.com/a/Ihjbw)

# To run regular version
```
main(<name of image file>)
```

# To run improved version
This alignment is not based on RGB similarity but based on edge similarity
```
mainEdge(<name of image file>)
```
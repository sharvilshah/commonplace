## This page is a markdown example

This page tests the rendering and displaying of Markdown content. It is called `markdown_test.md` and it's okay to delete it. It is also a pretty good example of how to structure content using markdown syntax, so you can also use it as a learning tool. 

### This headline separates things

> This is a blockquote. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

#### And this one separates more things, but is a bit smaller

To illustrate lists and how they work, here is the discography for [Boards of Canada](http://en.wikipedia.org/wiki/Boards_of_Canada). It also shows usage for bold and italics:

* *1995:* **"Twoism"** - (Music70)
* *1996:* **"Hi Scores"** - (Skam)
* *1998:* **"Aquarius"** - (Skam)
* *1998:* **Music Has the Right to Children** – (Warp/Skam)
* *1999:* **Peel Session TX 21/07/1998** (Warp)
* *2000:* **In a Beautiful Place Out in the Country** – (Warp/Music70)
* *2002:* **Geogaddi** – (Warp/Music70)
* *2005:* **The Campfire Headphase** – (Warp)
* *2006:* **Trans Canada Highway** (Warp)

## Here are a few links

* [This links to the Wikipedia page on Schrödinger's cat](http://en.wikipedia.org/wiki/Schr%C3%B6dinger's_cat)
* [This links to Commonplace's home](/)
* [This links to me on Twitter - so you can follow my tasty quips](http://twitter.com/f)


## How to include code snippets

Here's how you build a useless 20000 item array of, well, numbers up to 20000.

    var a = [];
    for(var i = 0; i < 20000; i++){
      a.push(0):
    }

And this is how you include inline snippets of code: `require 'commonplace'`

## Last, but most certainly not least

This is how you include amazing imagery from the wonderful world of the internet. Here's our sad Commonplace mechanical turk operator, also shown when you visit a page [that doesn't exist](/apagethatdoesntexistunlessyouareawesome).

![The sad sad mechanical turk operator](/img/sadturk.png)

## Final words

I hope this example file finds you well, and that you reach its very end happy and amused. If not, at least you're patient, because reading the kind of crap I write is, well, a spectacular waste of time. Maybe you'd like to [follow me on the worlds of twitter](http://twitter.com/f) to read more?

Your humble programmer slash designer slash writer, *Fred*.

```python
import math, sys

def sqrt(number, accuracy=5):
	"""
	implemented sqrt using newton's method
	Let's say we want to find square-root of n
	So x^2 = n, hence we find roots of that using newton's method
	We have:
	f(x) = x^2 - n 
	f'(x) = 2x
 	x1 = x0 - f(x0)/f'(x0)
 	x2 = x1 - f(x1)/f'(x1)
 	.
 	.
 	we stop after reaching the desired tolerance.
 	The default tolerance is 10^(-5) digits
	"""

	try:
		number = float(number)
	except ValueError:
		sys.exit('Input is not a number')

	# I can raise a value error here,
	# but the convention seems to be to return NaN (not a number)
	# NaN's are part of IEEE 754 floating point standard
	# and are standard as of python 2.6
	if number < 0:
		return float('nan')
	
	# tolerance : 10 ^ (-accuracy)
	tol = 10 ** (-1 * accuracy) 

	# x0: initial guess, average
	x0 = (number + 1)/2.0 
	result = x0

	while math.fabs((result ** 2) - number) >= tol:
		result = result - ((result ** 2 - number) / (2 * result))

	return result

if __name__ == '__main__':
	if len(sys.argv) < 2:
		sys.exit('Usage: %s <number>' % sys.argv[0])
	print sqrt(sys.argv[1])
```

```java
import static java.lang.Math.abs;
public class Sqrt {

	public static double sqrt(double number, int accuracy) {
		if (number < 0)
			return Double.NaN;
		double tol = Math.pow(10, -1*accuracy);
		double x0 = number < 1 ? (0+1)/2.0 : (1+number)/2.0;
		double result = x0;
		int count = 0;
		while (Math.abs(result*result - number) > tol) {
			result = result - ((result*result - number)/(2*result));
			count += 1;
		}
		System.out.println("count = "+count);
		return result;
	}

	public static double division(double N, double D) {
		if (D < 0)
			return Double.NaN;
		double tol = 0.001;
		double x0 = 1.0;
		double reciprocal = x0;
		while(Math.abs((1 - D*reciprocal)/reciprocal) > tol) {
			reciprocal = reciprocal*(2 - D*reciprocal);
		}
		return reciprocal;
	}

	public static void main(String[] args) {
		System.out.println(division(3.0,7.0));
	}
}
```
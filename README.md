# fft
Fast Fourier Transform

7.1 Lab Background
The Discrete Fourier Transform (DFT) can be implemented exactly using the Fast Fourier Transform (FFT). 
In addition you should be able to identify common problems using the DFT to analyze signals.
You will also be familiar with a new tool, the spectrogram, that uses the DFT as a function
of time.

7.2 Implementing the DFT
Recall that the DFT can be implemented directly from the analysis equation. For a length
N signal x[n],
X[k] =
NX􀀀1
n=0
x[n]e􀀀j 2
N nk for k = 0; 1; 2;   N 􀀀 1 (32)
The order of the implementation is O(N) = N2. The following Java code outlines implementation
of a 256-point DFT. It is written without any algorithmic speedup (i.e., it exactly
mirrors equation 32).
public class MyDFT
{
// x is the input and y is the magnitude of the complex DFT
public void computeDFT(double[] x, double[] y)
{
double[] yImag = new double[256];
double[] yReal = new double[256];
double twoPiOverN = 2*Math.PI/256;
for (int k = 0 ; k < 256 ; k++)
{
yReal[k] = 0;
yImag[k] = 0;
for (int n = 0 ; n < 256 ; n++)
{
yReal[k] += x[n]*Math.cos(n*k*twoPiOverN);
yImag[k] += 􀀀x[n]*Math.sin(n*k*twoPiOverN);
}
y[k] = Math.sqrt(yReal[k]*yReal[k] + yImag[k]*yImag[k]);
}
}
}

Note that, unlike in Matlab, there is no native support in Java for complex numbers
so this arithmetic is written out explicitly in the code above. For example, the equation
y = x  ea (where x is a real number) must be explicitly written out using Euler’s formula,
and the real and imaginary portions saved in separate variables, yreal = x  cos(a) and
yimag = x  sin(a).

The FFT algorithm can be used to reduce the computation time of the DFT to O(N) =
N log2 N — a significant speedup for even modest length signals.

7.3 The FFT in Matlab
Matlab includes a fft function (there are many more related operations in the Signal Processing
Toolbox, but we are sticking to “vanilla” Matlab here). You can look at the documentation
for this function; pay especial attention to the frequency values that correspond
to each element of the vector that this function returns, and to how to specify the number
of points in the FFT it computes.

Algorithm 6.2 Iterative FFT.
Require: x is a discrete function of time of length N
Ensure: X is the DFT of x (also of length N)
if N is not a power of two then
Pad x with zeros until its length is the next power of two
end if
Shue the x[n] in bit-reversed order
Size = 2 fSize = 1 DFTs already doneg while Size < N do
Compute N=Size DFTs from the existing ones as XSize=2[k]even +e􀀀jk2=SizeXSize=2[k]odd
Size = Size  2
end while

Step 1.1 Implement your own myFFT function in Matlab that takes a real-valued vector as
input, computes a 256-point FFT, and returns a real-valued vector that is the magnitude of
the (single-sided, i.e., only positive frequencies) FFT. Implement this function using loops
(i.e., do not use recursion). The first part of this code performs a bit reversal on the input
array. You can use the following code to perform the bit reversal efficiently (efficient bit
reversal algorithms in other languages are typically more complex):
% Assume that you want to do a bit reversal of the contents of the vector x
indices = [0 : length(x)􀀀1]; % binary indices need to start at zero
revIndices = bin2dec(fliplr(dec2bin(indices, 8))); % bit reversed indices
revX = x(revIndices+1); % Add 1 to get Matlab indices
This code converts the vector of in-order indices to an array of 8-character strings (representing
those indices as binary 8-bit numbers). Each string is then reversed, and converted
back to numbers. The resultant vector of indices (which is what they are after we add one
to each) is applied to the signal to pull its entries out into a new vector, with the order of
the entries in bit-reversed order.
Once you’ve done this, all you need to do is iterate over the array log2 N times! Remember
that you’re performing complex arithmetic and to compute the magnitude of the output array
once the FFT is computed. Include a copy of your Matlab code in your report.

Step 1.2 Check your results using the Matlab fft function. Your results should be quite
similar, if not identical; this should be apparent by comparing graphs of the outputs. Take the
FFT of a sinusoid with a frequency of =4 radians per second using your FFT implementation
and the fft function.

Step 1.3 Prove that the number of complex multiplies performed by your code is O(N logN).

7.4 Using the DFT
Step 2.1 Create a sum of two sinusoids. Use the built-in Matlab fft function (it will allow
you, among other things, to apply an n-point FFT to a signal with more than n samples) to
compute the FFT of the sum and then plot the FFT magnitude. Use frequencies of 0:13
and 0:19 for the two sinusoids. Make sure that there are at least 256 samples in each
waveform, as you’ll want to use a 256-point FFT! Also, make sure you correctly compute
the corresponding frequency values (either from 0 to  or 􀀀 to , depending on whether
you prefer plotting the single-sided magnitudes or not) for the FFT X-axis, and label it
appropriate in your graph. What does the result look like? Does this make sense?
Step 2.2 At what index (or indices) does the FFT magnitude reach its peak value(s)?
What frequency (or frequencies) does this correspond to?
Step 2.3 Change the frequencies of the sinusoids to 0:13 and 0:14. Repeat steps 2.1
and 2.2. Do the results still make sense?
Step 2.4 Replace the sum of two sinusoids with your DTMFCoder function from lab 6.
Input a selection of button values. Does the FFT block show the separate frequencies for
each button?

7.5 Spectrograms
Comparing FFT graphs (as in the step 2.4 above) can be difficult to do. But what if we
could analyze the frequency content of a signal as a function of time? That would make it
easier to see differences in frequency if a signal started changing (like a string of DTMF keys
pressed in turn). To do this we will need a new tool called the Spectrogram. The spectrogram
is simply an algorithm for computing the FFT of a signal at different times and plotting
them as a function of time. The spectrogram is computed in the following way:

1. A given signal is “windowed.” This means that we only take a certain number of points
from the signal (for this example assume we are using a window of length 128 points).
To start out, we take the first 128 points of the signal (points 1 through 128 of the
input vector).

2. Take the FFT of the window and save the it in a separate array.

3. Advance the window in time by a certain number of points. For instance we can
advance the window by 64 points so that we now have a window of indices 65 through
192 from the input signal array.

4. Repeat steps 1–3, saving the FFT of each window, until there are no longer any points
in the input array.
Signal Computing Laboratory Manual

5. Form a 2-D matrix whose columns are the FFT magnitudes of each window (placed
in chronological order). In this way, each row represents a certain frequency, each
column represents a given instant in time, and the value of the matrix represents the
magnitude of the FFT.

The result is called a spectrogram and is usually displayed as an RGB image where
blue represents small FFT magnitudes and red represents larger FFT magnitudes (the Jet
colormap if you are familiar with color visualizations). There is an art to choosing the correct
parameters of the spectrogram (i.e., window size, FFT size, how many points to advance
the FFT, etc.). Each parameter has tradeoffs for the time and frequency resolution of the
resulting spectrogram. For our purposes here, we will not be concerned with these tradeoffs.
Instead we will be more interested in getting familiar with analysis using spectrograms.
The Matlab Signal Processing Toolbox has a spectrogram function, but you can retrieve
a drop-in replacement for it from http://www.ee.columbia.edu/ln/rosa/matlab/
sgram/ that will work without that toolbox. See the online Matlab documentation for the
spectrogram function to understand what the parameters to that function are (though, for
our purposes, you should just be able to use the call y = myspecgram(x).

Step 3.1 Use your DTMFCoder function again. Instead of computing its FFT, compute
its spectrogram instead. What does the spectrogram look like for button 1? Are both
frequencies present?

Step 3.2 For this step, use DTMFCoder to generate the codes for multiple buttons — at
least three — and concatenate them together to form a single vector. Does the spectrogram
make it easier to judge the frequency content of the keys? Can you clearly see when the
signal changes from one key to another?
Signal Computing Laboratory Manual

*******************************************************************.
*   Field, A. & Gillett, R. (2009).   "How To Do Meta-Analysis".
*   British Journal of Mathematical and Statistical Psychology.
*******************************************************************.

* get number of studies (k) from number of rows in r-vector.
compute k = nrow(r).
* obtain adjusted values of r  (Overton, 1998, page 358).
compute ar = r - (r&*(1-r&**2))&/(2*(n-3)).
* create zr, Fisher's z-transformation of r.
compute zr = 0.5*ln((1+r)&/(1-r)).
* zr has variance = 1/(n-3)  (Field, 2001, page 164).
compute v = 1/(n-3).
* create fixed-effects weight vector.
compute w = 1/v.
* sum weights.
compute sw = csum(w).
* calculate c  (Hedges & Vevea, 1998, equation 10).
compute c = sw - t(w)*w/sw.
* calculate Q  (H & V equation 7).
compute q = t(w)*zr&**2 - (t(w)*zr)**2/sw.
* variance component tau is set equal to zero if Q < k-1,  and to  (q-k+1)/c  otherwise.
compute tau = mmax({0, (q-k+1)/c}).
* variance of effect size under random-effects model.
compute vt = v + tau.
* random-effects weight vector (H & V equation 13).
compute wt = 1/vt.
* sum weights.
compute swt = csum(wt).
* calculate Q for R-E.
compute qe = t(wt)*zr&**2 - (t(wt)*zr)**2/swt.

print /title = "**********   META-ANALYSIS OF CORRELATION COEFFICIENTS:  r   **********".
print {k}/clabels=k/format=f9.0/title = "NUMBER OF STUDIES".

* obtain weighted means (based on zr) for F-E and R-E models.
compute mean = {t(w)*zr/sw; t(wt)*zr/swt}.
* calculate standard errors and confidence intervals for means.
compute sem = {sqrt(1/sw); sqrt(1/swt)}.
compute ci = {mean - 1.96*sem, mean + 1.96*sem}.
* convert means and confidence intervals (based on zr) back to r.
compute rmean = (exp(2*mean)-1)&/(exp(2*mean)+1).
compute rci = (exp(2*ci)-1)&/(exp(2*ci)+1).
compute zscore = abs(mean&/sem).
compute pz = 2*(1 - cdfnorm(zscore)).
* calculate fsn (Rosenthal Fail-Safe N).
compute sezr = {sqrt(v), sqrt(vt)}.
compute fsn = (t(zr)*sqrt(n-3))**2/2.706 - k.
* standardise zr values across studies for F-E and R-E models ( Begg & Mazumdar, 1994).
compute vtilde = {v - 1/sw, vt - 1/swt}.
compute u = make(k,1,1).
compute zrstar = (zr*{1,1} - u*t(mean))&/sqrt(vtilde).

* Hunter-Schmidt random-effects analysis.
compute rav = csum(n&*r)/csum(n).
compute sr2 = csum(n&*((r-rav)&**2))/csum(n).
compute se2 = (1-rav**2)**2/((csum(n)/k)-1).
compute vrho = sr2-se2.

*if the variance in corrected correlations has a negative value, it indicates that the variance of corrected correlation is 0
(the variance attributable to artifacts is actually grater than the observed variance).
*do if - also, because the sqrt can not be obtained for negative values.

do if (vrho >=0).
compute sdrho = sqrt(vrho).
end if.

do if (vrho < 0).
compute sdrho = 0.
end if.

compute ciu = rav + (1.96*sdrho).
compute cil = rav - (1.96*sdrho).

compute chi = csum((n-1)&*(ar-rav)&**2)/(1-rav**2)**2.
compute chisig = 1 - chicdf(chi, k-1).

print /title = "**********   FIXED-EFFECTS MODEL   **********".
print {rmean(1), rci(1,1), rci(1,2), zscore(1), pz(1), k}/clabels='Mean r', 'Lower r', 'Upper r', z, p, k/format=f9.3/title='MEAN EFFECT SIZE, LOWER & UPPER 95% CONFIDENCE BOUNDS, AND Z-TEST '.
print {q, k-1, 1-chicdf({q}, k-1)}/clabels=Chi2, df,p/format=f9.3/title = "HOMOGENEITY TEST:  Q STATISTIC  (Goodness of Fit)".

print /title = "**********   HEDGES-VEVEA RANDOM-EFFECTS MODEL   **********".
print {rmean(2), rci(2,1), rci(2,2), zscore(2), pz(2), k}/clabels='Mean r', 'Lower r', 'Upper r', z, p, k/format=f9.3/title='MEAN EFFECT SIZE, LOWER & UPPER 95% CONFIDENCE BOUNDS, AND Z-TEST '.
print {tau}/clabels=Tau/format=f9.4 /title = "Estimated Variance in Population (Fisher-Transformed) Correlations".
print {qe, k-1, 1-chicdf({qe}, k-1)}/clabels=Chi2, df,p/format=f9.3/title = "HOMOGENEITY TEST:  Q STATISTIC  (Goodness of Fit)".

print /title = "**********   HUNTER-SCHMIDT RANDOM-EFFECTS MODEL   **********".
print {rav, cil, ciu, chi, chisig, (k-1)}/clabels='Mean r', 'Lower 95% CR', 'Upper 95% CR', Chi2, p, df/format=f9.3/title='MEAN EFFECT SIZE, LOWER & UPPER 95% CREDIBILITY BOUNDS, AND CHI-SQUARE TEST '.
print sr2 /format= f9.4 /title = "Sample Correlation Variance".
print se2 /format= f9.4 /Title = "Sampling Error Variance".
print vrho /format= f9.4 /title = "Estimated Variance in Population Correlations".

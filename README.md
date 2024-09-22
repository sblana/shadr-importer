For importing SHADR files into godot. Allows more efficient storage (~50%) and ease of use. Includes a 'SHADR' resource script, containing certain utility functions.

Spherical Harmonic ASCII Data Record (SHADR) is a file format used for storing coefficients and related information for a spherical harmonic gravity, topology, or other model.
See the SHADR [specification](https://pds-geosciences.wustl.edu/messenger/mess-h-rss_mla-5-sdp-v1/messrs_1001/document/shadr.txt) for more information on the format.

Issues:
- does not support importing covariance table
- slow (about 13s for a table with field degree 1200)
- the table file (.tab) has to be in the same directory as the header file (.lbl)

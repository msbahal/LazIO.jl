using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, String["liblaszip"], :liblaszip),
    # LibraryProduct(prefix, String["liblaszip_api"], :liblaszip_api),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/evetion/LASzipBuilder/releases/download/v0.2"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:i686, :glibc) => ("$bin_prefix/LASzipBuilder.v1.0.0.i686-linux-gnu.tar.gz", "5575096461fd9437ad126a5a41b347ec6185fa8725779336a17629f2779dbe76"),
    Windows(:i686) => ("$bin_prefix/LASzipBuilder.v1.0.0.i686-w64-mingw32.tar.gz", "b501e4241543a0a10c67fade31ed780f445fdb65704d3cf2db53257f2bda452a"),
    MacOS(:x86_64) => ("$bin_prefix/LASzipBuilder.v1.0.0.x86_64-apple-darwin14.tar.gz", "05e2d4337a1814866836f3c4d0ed98d212417a7e99a1dd0072dddbfe335040a4"),
    Linux(:x86_64, :glibc) => ("$bin_prefix/LASzipBuilder.v1.0.0.x86_64-linux-gnu.tar.gz", "4f11f8c21a575b9e1ca150ca8bb7db4147b70e96fa132129057dbb7a92aaf779"),
    Windows(:x86_64) => ("$bin_prefix/LASzipBuilder.v1.0.0.x86_64-w64-mingw32.tar.gz", "63ff74dfd9f0468e1dc9263d7d5b4d1ad346437290cb3e00f961e27a6f628814"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    if unsatisfied || !isinstalled(url, tarball_hash; prefix=prefix)
        # Download and install binaries
        install(url, tarball_hash; prefix=prefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform $(triplet(platform_key())) is not supported by this package!")
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products)

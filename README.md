<div align="center">
    <img src="./resources/icon.png" width="256" alt="toucant icon" />
</div>

# toucant

**toucant** is a demotivational app made with 😭

## Server

The `/server` is completely written in Rust and uses [Axum](https://github.com/tokio-rs/axum) as well as [Serde](https://serde.rs/). 

Currently, the only route is `/api/daily` which returns your daily demotivational quote! The server starts on `0.0.0.0:3000`. During development, you can also run `cargo doc --open` to view the documentation. 

Extending the daily demotivational quote catalog is as simple as adding new quotes and quizzes to the `/server/data.json` file.

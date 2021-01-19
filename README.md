# Sentiment Analysis

Sentiment analysis is an HTTP service that uses [TensorFlow.js](https://www.tensorflow.org/js) to analyse sentences for sentiment.

## Format

The service accepts POST requests at `/toxicity` containing the following JSON body:

```json
{
    "sentences": [
        "This is a bad sentence!"
    ],
    "threshold": 0.9
}
```

And outputs a response so:

```json
[
    {
        "label": "This is a bad sentence!",
        "sentiment": {
            "identityAttack": {
                "match": false,
                "probability0": 0.9999154806137085,
                "probability1": 8.451499161310494e-05
            },
            "insult": {
                "match": false,
                "probability0": 0.9967449903488159,
                "probability1": 0.00325503246858716
            },
            "obscene": {
                "match": false,
                "probability0": 0.9997777342796326,
                "probability1": 0.00022223764972295612
            },
            "severeToxicity": {
                "match": false,
                "probability0": 0.9999998807907104,
                "probability1": 1.2195648935175996e-07
            },
            "sexualExplicit": {
                "match": false,
                "probability0": 0.9998600482940674,
                "probability1": 0.00013990982552058995
            },
            "threat": {
                "match": false,
                "probability0": 0.9997361302375793,
                "probability1": 0.0002638357982505113
            },
            "toxicity": {
                "match": false,
                "probability0": 0.9944095015525818,
                "probability1": 0.005590534768998623
            }
        }
    }
]
```

The `$BASE_URL` environment variable is optional, it defaults to an empty string.

## Usage

You can run the service locally by running:

```sh
npm install
npx spago run
# or
HOST=0.0.0.0 PORT:9001 npx spago run
```

The service by default listens on host `0.0.0.0` and port `9000`, but this can be configured using the environment variables `HOST` and `PORT`.

## Deployment

A [Dockerfile](./docker/Dockerfile) has been provided and it can be used for the deployment, e.g.:

```sh
docker build -t="hivemind/sentiment-analysis" -f docker/Dockerfile .
docker run -ti -p 9000:9000 -e HOST=0.0.0.0 -e PORT=9000 hivemind/sentiment-analysis:latest
```

Test it e.g. using [httpie](https://httpie.org):

```sh
http -v POST http://localhost:9000/toxicity threshold:=0.9 sentences:='["This is a bad sentence!"]'
```

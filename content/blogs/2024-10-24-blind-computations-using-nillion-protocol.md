---
date: 2024-10-24T00:00:00Z
title: Implementing Blind Computation using Nillion Protocol
---

> A comprehensive guide on how to implement blind computations (computing on encrypted variables without ever decrypting them) using Nillion protocol.

# Introduction

So what is the meaning of blind computation ? What are its advantages ?

I recently participated in [ETHGlobal](https://ethglobal.com/)’s [ETHOnline’24](https://ethglobal.com/events/ethonline2024) hackathon, and my team built a decentarlized roulette platform ([FairBet](https://github.com/aaravm/FairBET)) with the help of [Nillion](https://nillion.com/) and [Sign Protocol](https://sign.global/), and won a partner prize too !!

%[https://x.com/lla_dane/status/1839514686351421874] 

I worked on implementing a blind computation infrastructure using Nillion so that the result of the game gets calculated not on the open backend or frontend which could be easily manipulated by malicious entities, but on a secure blockchain environment on which the variables are dispersed over the network and also encrypted when they are computed upon !! So not chance of tampering with the result.

# What exactly Nillion does ?

Nillion is a secure computation network that decentralizes trust for high value data in the same way that blockchains decentralized transactions.

Traditionally securing high value data requires encryption before storage. While this is effective for safeguarding the data at rest, it creates limitations when the data needs to be used or processed.  
Once the data is encrypted and stored, the traditional process involves decrypting it to perform necessary computations, and the re-encrypting it. This decrypt-compute-reencrypt cycle not only causes potential security vulnerabilities, but also leads to inefficiencies in data handling !!

Nillion addresses these challenges by leveraging privacy enhancing technologies (PETs) including Multi-Party Computation (MPC). These PETs enable users to securely store high value data on Nillion's peer-to-peer network of nodes, and allow for computations to be executed on the masked data itself. This eliminates the traditional need to decrypt data ahead of computation, enhancing the high value data's security.

**In short, high value data stored in the Nillion Network can be computed on while staying hidden (encrypted).**

# How we used Nillion ?

As I mentioned before, we used it for data security in a roulette game. A user’s bet remain completely private, stored on Nillion’s devnet, making it inaccessible to anyone - including game administrators. Once the roulette wheel is spun, and it generates a result, it sent to the Nillion backend server, which privately computes whether the user won or lost. The result is returned securely, without exposing any sensitive data. This ensures that neither the game makers nor external actors can influence the outcome, promoting fairness and transparency.

# How we built it ?

Like everyone else we referred to the developer [docs](https://docs.nillion.com/start-building) to get started. Basically the thing is, you have to implement nillion clients in python or java-script to interact with the nillion network. I went for the python client and below I will show you, how I built it.

For the nillion-python-development environment setup refer to the docs. This will get you installed with Nillion SDK Tools and nilup.

Fork and clone the [Nillion-pyhton-starter repo](https://github.com/NillionNetwork/nillion-python-starter):

```bash
git clone https://github.com/<your-github-username>/nillion-python-starter.git
cd nillion-python-starter
```

After that install the required dependencies and tools as mentioned in the docs.

### Nillion-Secret Programs

First let’s get on with the nada-programs. A binary of these programs will be deployed along with the compute variables to the nillion-devnet for blind computations.

```bash
cd quickstart
nada init nada_quickstart_programs
```

This will generate a simple secret-addition.py program that looks like this -

```python
from nada_dsl import *

def nada_main():
    party1 = Party(name="Party1")
    my_int1 = SecretInteger(Input(name="my_int1", party=party1))
    my_int2 = SecretInteger(Input(name="my_int2", party=party1))
    new_int = my_int1 + my_int2
    return [Output(new_int, "my_output", party1)]
```

The one thing to watch-out for is the ownership of variables. You must use the party name for secret integers, from which they were deployed in the first place from the client code.

I wrote a [check\_equal.py](https://github.com/aaravm/FairBET/blob/master/nillion-python-starter/quickstart/nada_quickstart_programs/src/check_equal.py) file for checking if the user’s bet and the upcoming target on which the ball would land, intersect ? If they do then the player won and vice versa.

```python
import json
from nada_dsl import *
import os

def is_guess_in_target(array: List[SecretInteger], value: Integer) -> SecretBoolean:
    result = Integer(0)
    for element in array:
        result += (value == element).if_else(Integer(1), Integer(0))
    return (result > Integer(0))

def nada_main():
    user = Party(name="PLAYER")
    game = Party(name="GAME_MANAGER")
    
    secret_targets = [
        SecretInteger(Input(name=f"SECRET_TARGETS_{i}", party=game)) for i in range(5)
    ]
    
    secret_guess = SecretInteger(Input(name="SECRET_GUESS", party=user))
    is_present = is_guess_in_target(secret_targets, secret_guess)

    return [Output(is_present, "BET_RESULT", game)]
```

So basically what’s happening is, for a particular target there could be 5 winning bets in roulette, so when the target is received from the frontend, the numeric codes corresponding to the winning bets are deployed along with the player’s bet.

That’s happening in the ***secret\_targets*** *and* ***secret\_guess.*** After that if the ***secret\_guess*** is in the ***secret\_target*** array, **true** is returned to nillion-client, otherwise **false**.  
All this happens without ever knowing the actual values to targets or guess, so it cannot be tampered with. Cool isn’t !!

I also wrote a ***random\_shuffling.py*** script, which will be distribute cards to the existing players truely randomly without any tampering. Check it out [here](https://github.com/aaravm/FairBET/blob/master/nillion-python-starter/quickstart/nada_quickstart_programs/src/random_shuffle.py).

Now let’s get on with the client code.

### Nillion-Clients

Clients are required to store and retrieve secrets from the nillion-devnet.

I wrote a [slots.py](https://github.com/aaravm/FairBET/blob/master/nillion-python-starter/quickstart/client_code/slots.py) script that fetches the target and guess value from the running flask server, and then deploys the target array, guess and check.equal.py script over the nillion-devent and returns the result of the game as TRUE/FALSE.

Refer to the complete code [here](https://github.com/aaravm/FairBET/blob/master/nillion-python-starter/quickstart/client_code/slots.py)

I will guide step by step the important components of the code.

1.  Fetching the ***secret\_target*** and ***secret\_guess*** and generate the ***SECRET\_TARGETS*** array
    
    ```python
        target = await fetch_target()
        SECRET_GUESS = await fetch_guess()
        SECRET_TARGETS = generate_secret_target(target)
    ```
    
2.  Set up the player and game-manager client
    
    ```python
    # PLAYER
        seed = PLAYER_ALIAS
        user_key = UserKey.from_seed(seed)
        node_key = NodeKey.from_seed(seed)
        PLAYER_CLIENT = create_nillion_client(user_key, node_key)
       
    # GAME-MANAGER
        manager_seed = MANAGER
        user_key = UserKey.from_seed(manager_seed)
        node_key = NodeKey.from_seed(manager_seed)
        MANAGER_CLIENT = create_nillion_client(user_key, node_key)
    ```
    

After that retrieve the nillion-devnet env configurations and with it set up the payments wallet as given in the code.

3.  Deploy the ***check\_equal.py*** program under the ownership of game-manager, that means only the game-manager can use that program for computations.
    
    ```python
     # DEPLOY THE PROGRAM BY GAME MANAGER
        
        CHECK_EQUAL_PROGRAM = "check_equal"
        PROGRAM_PATH = f"../nada_quickstart_programs/target/{CHECK_EQUAL_PROGRAM}.nada.bin"
        
        check_equal_program_receipt = await get_quote_and_pay(
            MANAGER_CLIENT,
            nillion.Operation.store_program(PROGRAM_PATH),
            payments_wallet,
            payments_client,
            cluster_id,
        )
        
        action_id = await MANAGER_CLIENT.store_program(
            cluster_id, CHECK_EQUAL_PROGRAM, PROGRAM_PATH, check_equal_program_receipt
        )
        
        PROGRAM_ID = f'{manager_user_id}/{CHECK_EQUAL_PROGRAM}'
    ```
    
4.  Deploy the ***secret\_guess*** under the ownership of the ***player-client*** and give out permissions that which entities could compute over these variables i.e. verify\_equal.py.
    
    ```python
    # DEPLOY THE SECRET_GUESS BY THE PLAYER
    
        player_secrets = nillion.NadaValues(
            {"SECRET_GUESS": nillion.SecretInteger(SECRET_GUESS)}
        )
    
        permissions = nillion.Permissions.default_for_user(player_user_id)    
        permissions.add_compute_permissions({PLAYER_CLIENT.user_id: {PROGRAM_ID}})
        permissions.add_compute_permissions({MANAGER_CLIENT.user_id: {PROGRAM_ID}})
        
        receipt_store = await get_quote_and_pay(
            PLAYER_CLIENT,
            nillion.Operation.store_values(player_secrets, ttl_days=5),
            payments_wallet,
            payments_client,
            cluster_id,
        )
        
        guess_store_id = await PLAYER_CLIENT.store_values(
            cluster_id, player_secrets, permissions, receipt_store
        )
    ```
    
5.  In the same way deploy the ***SECRET\_TARGETS*** under the ownership of game-manager client.
    
    ```python
    # DEPLOY THE SECRET_TARGETS BY THE GAME-MANAGER
    
        manager_secrets = nillion.NadaValues(
            {f"SECRET_TARGETS_{i}": nillion.SecretInteger(SECRET_TARGETS[i]) for i in range(len(SECRET_TARGETS))}
        )
    
        permissions = nillion.Permissions.default_for_user(manager_user_id)    
        permissions.add_compute_permissions({PLAYER_CLIENT.user_id: {PROGRAM_ID}})
        permissions.add_compute_permissions({MANAGER_CLIENT.user_id: {PROGRAM_ID}})
        
        receipt_store = await get_quote_and_pay(
            MANAGER_CLIENT,
            nillion.Operation.store_values(manager_secrets, ttl_days=5),
            payments_wallet,
            payments_client,
            cluster_id,
        )
        
        target_store_id = await MANAGER_CLIENT.store_values(
            cluster_id, manager_secrets, permissions, receipt_store
        )
    ```
    
6.  Set up compute bindings the input parties (inputs are under the ownership of which parties ?) and output parties (outputs will be under the ownership of which parties) and then finally execute the blind computation.
    
    ```python
    # SET UP COMPUTATION OF THE SECRETS
        compute_bindings = nillion.ProgramBindings(PROGRAM_ID)
        compute_bindings.add_input_party(PLAYER_ALIAS, player_party_id)  # Ensure the correct input party is added
        compute_bindings.add_input_party(MANAGER, manager_party_id)  # Add Game Manager as input party
        compute_bindings.add_output_party(MANAGER, manager_party_id)
    
        COMPUTE_SECRETS = nillion.NadaValues({})
    
        receipt_compute = await get_quote_and_pay(
            MANAGER_CLIENT,
            nillion.Operation.compute(PROGRAM_ID, COMPUTE_SECRETS),
            payments_wallet,
            payments_client,
            cluster_id
        )
    
        compute_id = await MANAGER_CLIENT.compute(
            cluster_id,
            compute_bindings,
            [guess_store_id, target_store_id],
            COMPUTE_SECRETS,
            receipt_compute
        )
    ```
    
7.  Extract the result and return it back to the running flask server.
    
    ```python
    while True:
            compute_event = await MANAGER_CLIENT.next_compute_event()
            if isinstance(compute_event, nillion.ComputeFinishedEvent):
                print(compute_event.result.value)
                return compute_event.result.value
    ```
    

So this is how you can execute a blind computation using Nillion-SDK. I know that all the ownership and other configurations could be a little bit confusing, ***but at the same time security comes with some low level complexities right ?***

I also wrote a couple of more client scripts:

*   [***game\_manager.py***](https://github.com/aaravm/FairBET/blob/master/nillion-python-starter/quickstart/client_code/game_manager.py)***:*** This client executes the blind computation program that I mentioned earlier and the result is a tamper-proof random and blind shuffling. This client was intended for the blackjack game.
    

# Conclusion

As Nillion is in early development phase, we faced a lot of problems with simple boolean operators and variable types. Only integer type variables could be operated upon, so that reduces the scope of development. But I am sure Nillion will expand its developer environment.

We also participated in **ETHSingapore’24** organised during 20th-22nd September 2024. There we built a lending platform on Oasis Sapphire blockchain with on-chain and off-chain confidentiality. We won a partner prize too !!

%[https://x.com/lla_dane/status/1839519548984189277] 

It has been a great learning experience from participating in **ETHGlobal** hackathons, met a tonn of amazing people in the web3 space, and can’t wait for more !!

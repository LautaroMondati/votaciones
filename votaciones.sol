// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <= 0.8.7;
pragma experimental ABIEncoderV2;

contract votaciones {
    address owner;
    struct candidato{
        string nombreApellido;
        uint edad;
        uint votos;
        string claveVoto;
    }
    mapping (bytes32 => candidato) InfoCandidatos;
    bytes32 [] candidatos;
    bytes32 [] votantes; 
    
    constructor () {
        owner = msg.sender;
    }

    modifier NuevoCandidato(string memory _id){
        bool doesntListContainElement = true;
        bytes32 hashCandidato = keccak256(abi.encodePacked(_id));
        for (uint i=0; i < candidatos.length; i++) {
            if (hashCandidato == candidatos[i]) {
                doesntListContainElement = false;
            }
        }
        require(doesntListContainElement, "Este candidato ya se encuentra registrado.");
        _;
    }

    modifier NuevoVotante(string memory _idVotante){
        bool doesntListContainElement = true;
        bytes32 hashVotante = keccak256(abi.encodePacked(_idVotante));
        for (uint i=0; i < votantes.length; i++) {
            if (hashVotante == votantes[i]) {
                doesntListContainElement = false;
            }
        }
        require(doesntListContainElement, "Usted ya ha realizado su voto.");
        _;
    }

    function Representar (string memory _nombreApellido, uint _edad, string memory _id) public NuevoCandidato(_id){
        bytes32 hashCandidato = keccak256(abi.encodePacked(_id));
        InfoCandidatos[hashCandidato] = candidato(_nombreApellido, _edad, 0, _id);
        candidatos.push(hashCandidato);
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
    
    function VerCandidatos() public view returns(string memory){
        string memory resultados = "";
        for (uint i=0; i<candidatos.length; i++){
            resultados = string(abi.encodePacked(resultados, "*",InfoCandidatos[candidatos[i]].nombreApellido, ":", InfoCandidatos[candidatos[i]].claveVoto));
        }
        return resultados;
    }
    
    function ChequearCandidato(bytes32 _idCandidato) private view returns(bool){
        bool doesListContainElement = false;
        for (uint i=0; i < candidatos.length; i++) {
            if (_idCandidato == candidatos[i]) {
                doesListContainElement = true;
            }
        }
        return doesListContainElement;
    }

    function Votar(string memory _idCandidato, string memory _idVotante) public NuevoVotante(_idVotante){
        bytes32 hashCandidato = keccak256(abi.encodePacked(_idCandidato));
        bytes32 hashVotante = keccak256(abi.encodePacked(_idVotante));
        require(ChequearCandidato(hashCandidato), "El candidato elegido no existe.");
        InfoCandidatos[hashCandidato].votos = InfoCandidatos[hashCandidato].votos + 1;
        votantes.push(hashVotante);
    }

    function Resultados() public view returns(string memory){
        if(candidatos.length>0){
            string memory resultadosVotacion = "";
            for (uint i=0; i<candidatos.length; i++){
                resultadosVotacion = string(abi.encodePacked(resultadosVotacion, "*",InfoCandidatos[candidatos[i]].nombreApellido, ":", uint2str((InfoCandidatos[candidatos[i]].votos * 100)/votantes.length)));
            }
            return resultadosVotacion;
        }
        return "No se han realizado votos.";
    }
}
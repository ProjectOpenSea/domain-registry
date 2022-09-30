import { expect } from "chai";
import { keccak256, toUtf8Bytes } from "ethers/lib/utils";
import { ethers, network } from "hardhat";

import { VERSION } from "./utils/helpers";

import type { DomainRegistryInterface } from "../typechain-types/interfaces";

describe(`Domain Registry v${VERSION})`, function () {
  let domainRegistryContract: DomainRegistryInterface;
  const openseaDomain = "opensea.io";
  const localHashOfOpenseaDomain = keccak256(toUtf8Bytes(openseaDomain)).slice(
    0,
    10
  );

  after(async () => {
    await network.provider.request({
      method: "hardhat_reset",
    });
  });

  beforeEach(async () => {
    const DomainRegistryContractFactory = await ethers.getContractFactory(
      "DomainRegistry"
    );
    domainRegistryContract = await DomainRegistryContractFactory.deploy();
  });

  describe("setDomain", async () => {
    it("Should register a new domain and emit a DomainRegistered event", async () => {
      const setDomainTransaction = await domainRegistryContract.setDomain(
        openseaDomain
      );

      expect(setDomainTransaction)
        .to.emit(domainRegistryContract, "DomainRegistered")
        .withArgs(openseaDomain, localHashOfOpenseaDomain, 0);
    });

    it("Should revert if the domain has already been registered", async () => {
      await domainRegistryContract.setDomain(openseaDomain);

      await expect(domainRegistryContract.setDomain(openseaDomain))
        .to.be.revertedWithCustomError(
          domainRegistryContract,
          "DomainAlreadyRegistered"
        )
        .withArgs(openseaDomain);
    });
  });

  describe("getDomains", async () => {
    it("Should return the array of registered domains for the passed in tag", async () => {
      await domainRegistryContract.setDomain(openseaDomain);

      expect(
        await domainRegistryContract.getDomains(localHashOfOpenseaDomain)
      ).to.deep.eq([openseaDomain]);
    });

    it("Should return multiple domains if more than one domain has been registered for the passed in tag", async () => {
      const tag = "0xa9059cbb";

      const expectedDomainArray = [
        "join_tg_invmru_haha_fd06787(address,bool)",
        "func_2093253501(bytes)",
        "transfer(bytes4[9],bytes5[6],int48[11])",
        "many_msg_babbage(bytes1)",
      ];

      await domainRegistryContract.setDomain(expectedDomainArray[0]);

      await domainRegistryContract.setDomain(expectedDomainArray[1]);

      await domainRegistryContract.setDomain(expectedDomainArray[2]);

      await domainRegistryContract.setDomain(expectedDomainArray[3]);

      expect(await domainRegistryContract.getDomains(tag)).to.deep.eq(
        expectedDomainArray
      );
    });
  });

  describe("getTotalDomains", async () => {
    it("Should return the total number of registered domains for a given tag", async () => {
      await domainRegistryContract.setDomain(openseaDomain);

      expect(
        await domainRegistryContract.getTotalDomains(localHashOfOpenseaDomain)
      ).to.eq(1);
    });
  });

  describe("getDomain", async () => {
    it("Should revert if the index is out of bounds", async () => {
      await domainRegistryContract.setDomain(openseaDomain);

      await expect(
        domainRegistryContract.getDomain(localHashOfOpenseaDomain, 4)
      )
        .to.be.revertedWithCustomError(
          domainRegistryContract,
          "DomainIndexOutOfRange"
        )
        .withArgs(localHashOfOpenseaDomain, 1, 4);
    });
  });
});
